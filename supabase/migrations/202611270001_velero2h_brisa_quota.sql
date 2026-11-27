begin;
create schema if not exists secureapp_private;
revoke all on schema secureapp_private from public, anon, authenticated;
create table if not exists secureapp_private.brisa_quota (
  user_id uuid primary key references auth.users(id) on delete cascade,
  minute_bucket timestamptz not null,
  minute_count integer not null check (minute_count >= 0),
  day_bucket date not null,
  day_count integer not null check (day_count >= 0)
);
alter table secureapp_private.brisa_quota enable row level security;
revoke all on secureapp_private.brisa_quota from public, anon, authenticated;
create or replace function public.velero2h_brisa_quota()
returns boolean language plpgsql security definer set search_path = '' as $$
declare
  uid uuid := auth.uid();
  minute_now timestamptz := date_trunc('minute', now());
  day_now date := (now() at time zone 'UTC')::date;
  accepted integer;
begin
  if uid is null then return false; end if;
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
