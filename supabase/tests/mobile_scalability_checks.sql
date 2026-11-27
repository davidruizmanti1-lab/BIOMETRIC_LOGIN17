-- Comprobaciones no destructivas de índice y seguridad.
select exists (
  select 1 from pg_indexes
  where schemaname = 'secureapp_private' and tablename = 'access_log'
    and indexname = 'access_log_user_accessed_idx'
) as access_index_present,
not has_table_privilege('anon','secureapp_private.access_log','SELECT') as anon_access_denied,
not has_table_privilege('authenticated','secureapp_private.access_log','SELECT') as direct_access_denied,
(select relrowsecurity from pg_class
  where oid = 'secureapp_private.access_log'::regclass) as rls_enabled;
