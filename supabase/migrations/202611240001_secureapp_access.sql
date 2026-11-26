begin;

create schema if not exists secureapp_private;
revoke all on schema secureapp_private from public, anon, authenticated;

create table if not exists secureapp_private.access_log (
    session_id uuid primary key,
    user_id uuid not null references auth.users(id) on delete cascade,
    accessed_at timestamptz not null default now()
);

alter table secureapp_private.access_log enable row level security;
revoke all on table secureapp_private.access_log from public, anon, authenticated;

create or replace function public.secureapp_register_access()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
    account_id uuid := auth.uid();
    login_session uuid := nullif(auth.jwt() ->> 'session_id', '')::uuid;
begin
    if account_id is null or login_session is null then
        raise exception 'Authentication required' using errcode = '42501';
    end if;

    insert into secureapp_private.access_log (session_id, user_id)
    values (login_session, account_id)
    on conflict (session_id) do nothing;
end;
$$;

revoke all on function public.secureapp_register_access() from public, anon, authenticated;
grant execute on function public.secureapp_register_access() to authenticated;

commit;
