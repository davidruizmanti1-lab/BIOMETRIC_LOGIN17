# Activar BRISA real en el Supabase original

1. Abre el proyecto dedicado de SecureApp/Velero2H, no otro proyecto. Comprueba que la migración de acceso original ya existe y que los registros públicos están deshabilitados.
2. Ejecuta en SQL Editor supabase/migrations/202611270001_velero2h_brisa_quota.sql si aún no está aplicada. No expongas secureapp_private.
Antes del paso 3 aplica también 202611270002_brisa_session_guard.sql y ejecuta supabase/tests/brisa_permissions.sql. BRISA requiere un registro de acceso reciente (30 minutos) y no revocado. Pasado ese plazo, vuelve a iniciar sesión.

3. Despliega supabase/functions/brisa/index.ts como Edge Function brisa con verificación de JWT habilitada. También valida el usuario explícitamente en la función.
4. En Edge Functions > Secrets, configura BRISA_AI_API_KEY y BRISA_AI_MODEL con los datos de tu proveedor Groq. Elige un modelo disponible en tu cuenta. No pegues claves en GitHub ni Flutter.
5. En secureapp.config.json local, añade "VELERO2H_BRISA_AI": "true" conservando las variables de Supabase originales.
6. Reconstruye con flutter run --dart-define-from-file=secureapp.config.json. Inicia sesión con una cuenta autorizada y activa IA en línea en BRISA.
7. Prueba: pregunta por precio y reserva; debe indicar IA en línea si recibió temas válidos. Una caída o rechazo mantiene la guía local y no muestra un falso éxito. Prueba también cierre de sesión, consultas personales rechazadas y límites.
8. No hay reserva automática, consulta de disponibilidad en vivo ni cobros. La IA clasifica preguntas; la aplicación responde exclusivamente a partir de su guía autorizada. Las preguntas generales se envían al proveedor cuando el usuario habilita IA. Los límites son 5 por minuto y 40 por día por usuario.

No se requieren contraseñas de los usuarios ni claves de servicio en el repositorio. El despliegue y las pruebas reales requieren acceso autorizado a Supabase.

La revocación remota depende de la conexión; no se promete revocación instantánea sin red. El registro de acceso de la aplicación no constituye una prueba criptográfica de biometría. Las peticiones iniciadas antes del cierre pueden completar en el servidor aunque la app descarte sus resultados. No desplegar sobre producción sin revisar las migraciones.
