-- Indexa la FK y prepara consultas de historial por usuario.
create index if not exists access_log_user_accessed_idx on secureapp_private.access_log (user_id, accessed_at desc);
