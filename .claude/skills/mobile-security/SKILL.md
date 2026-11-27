---
name: mobile-security
description: Audita y mejora la seguridad de Velero2H Flutter, Android y Supabase sin debilitar controles ni exponer datos.
---
# Seguridad móvil
- Lee el diff, AuthController, repositorios y migraciones pertinentes.
- Conserva HTTPS sin redirecciones, límites de respuesta y tiempos máximos.
- Comprueba biometría, segundo plano, cierre de sesión, respuestas tardías y tokens solo en memoria. No confundas biometría local con prueba remota.
- Comprueba FLAG_SECURE, permisos mínimos, copias de seguridad desactivadas y claves fuera del APK.
- Revisa RLS, grants, SECURITY DEFINER con search_path vacío y auth.uid() en RPC.
- No hagas pruebas sobre cuentas reales sin autorización específica ni modifiques producción sin revisar.
- Añade pruebas negativas y registra evidencia, riesgo y mitigación. No prometas invulnerabilidad.
