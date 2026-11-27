-- Ejecutar después de las dos migraciones BRISA.
select
  not has_table_privilege('authenticated','secureapp_private.brisa_revoked_sessions','SELECT') as revoked_private,
  not has_table_privilege('authenticated','secureapp_private.brisa_quota','UPDATE') as quota_private,
  not has_function_privilege('anon','public.velero2h_brisa_revoke()','EXECUTE') as anon_revoke_denied,
  not has_function_privilege('anon','public.velero2h_brisa_quota()','EXECUTE') as anon_quota_denied,
  has_function_privilege('authenticated','public.velero2h_brisa_revoke()','EXECUTE') as auth_revoke_allowed,
  (select relrowsecurity from pg_class where oid='secureapp_private.brisa_revoked_sessions'::regclass) as rls_enabled;
