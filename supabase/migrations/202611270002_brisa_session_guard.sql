begin;

create table if not exists secureapp_private.brisa_revoked_sessions (
  session_id uuid primary key,
  revoked_at timestamptz not null default now()
);
alter table secureapp_private.brisa_revoked_sessions enable row level security;
revoke all on secureapp_private.brisa_revoked_sessions from public, anon, authenticated;

create or replace function public.velero2h_brisa_revoke()
returns void language plpgsql security definer set search_path = '' as $$
declare
  sid uuid := nullif(auth.jwt() ->> 'session_id', '')::uuid;
begin
  if auth.uid() is null or sid is null then
    raise exception 'Authentication required' using errcode = '42501';
  end if;
  insert into secureapp_private.brisa_revoked_sessions(session_id)
    values (sid) on conflict (session_id) do nothing;
end;
$$;
revoke all on function public.velero2h_brisa_revoke() from public, anon, authenticated;
grant execute on function public.velero2h_brisa_revoke() to authenticated;

create or replace function public.velero2h_brisa_quota()
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  minute_now timestamptz := date_trunc('minute', now());
  day_now date := (now() at time zone 'UTC')::date;
  accepted integer;
  sid uuid := nullif(auth.jwt() ->> 'session_id', '')::uuid;
begin
  if uid is null or sid is null then return false; end if;
  if not exists (
    select 1 from secureapp_private.access_log a
    where a.session_id = sid and a.user_id = uid
      and a.accessed_at > now() - interval '30 minutes'
  ) or exists (
    select 1 from secureapp_private.brisa_revoked_sessions r
    where r.session_id = sid
  ) then return false; end if;
  insert into secureapp_private.brisa_quota as q (user_id,minute_bucket,minute_count,day_bucket,day_count)
    values (uid,minute_now,1,day_now,1)
    on conflict (user_id) do update set
      minute_count = case when q.minute_bucket = minute_now then q.minute_count+1 else 1 end,
      minute_bucket = minute_now,
      day_count = case when q.day_bucket = day_now then q.day_count+1 else 1 end,
      day_bucket = day_now
    where (q.minute_bucket <> minute_now or q.minute_count < 5)
      and (q.day_bucket <> day_now or q.day_count < 40)
    returning 1 into accepted;
  return coalesce(accepted = 1,false);
end;
$$;
revoke all on function public.velero2h_brisa_quota() from public, anon, authenticated;
grant execute on function public.velero2h_brisa_quota() to authenticated;
commit;
