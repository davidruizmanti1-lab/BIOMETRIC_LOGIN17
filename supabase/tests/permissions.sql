select
    not has_schema_privilege('anon', 'secureapp_private', 'USAGE') as anon_schema_denied,
    not has_schema_privilege('authenticated', 'secureapp_private', 'USAGE') as user_schema_denied,
    not has_table_privilege('anon', 'secureapp_private.access_log', 'SELECT') as anon_read_denied,
    not has_table_privilege('authenticated', 'secureapp_private.access_log', 'SELECT') as user_read_denied,
    not has_table_privilege('authenticated', 'secureapp_private.access_log', 'INSERT') as user_direct_insert_denied,
    not has_table_privilege('authenticated', 'secureapp_private.access_log', 'UPDATE') as user_update_denied,
    not has_table_privilege('authenticated', 'secureapp_private.access_log', 'DELETE') as user_delete_denied,
    not has_function_privilege('anon', 'public.secureapp_register_access()', 'EXECUTE') as anon_rpc_denied,
    has_function_privilege('authenticated', 'public.secureapp_register_access()', 'EXECUTE') as user_rpc_allowed,
    (select relrowsecurity from pg_class where oid = 'secureapp_private.access_log'::regclass) as rls_enabled;
