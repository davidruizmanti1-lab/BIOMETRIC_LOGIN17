# Velero2H Mobile · Aqua Luxury

Nueva edición móvil: [Guía de instalación y funciones](docs/VELERO2H_MOBILE.md).

## Proyecto original y autenticación

Proyecto académico de Desarrollo de Aplicaciones Móviles, David Ruiz y Karen Meneses. Universidad Pontificia Bolivariana, Seccional Bucaramanga.

Aplicación Flutter para Android que combina autenticación local (huella, rostro o credencial del dispositivo, según el botón escogido) con una cuenta de Supabase Auth y un registro remoto privado. La aplicación no registra huellas, no contiene una lista de usuarios ni descarga la tabla de auditoría.

## Conexión al proyecto Velero2H actual

La app de esta rama solo admite el proyecto de producción `xsbrwkxptxqnfdzvygwl`. Las cuatro migraciones del módulo móvil ya fueron aplicadas allí. No repetirlas para solucionar errores de contraseña o conexión.

1. Desde PowerShell en VS Code, ejecuta `powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Configurar-Supabase.ps1"`.
2. Introduce la clave publicable del proyecto (Settings → API Keys). El script verifica Auth antes de guardar la configuración local, y no muestra ni registra la clave.
3. Ejecuta `powershell -NoProfile -ExecutionPolicy Bypass -File ".\scripts\Diagnosticar-Supabase.ps1"`.
4. Ejecuta `flutter run --dart-define-from-file=secureapp.config.json` y selecciona Android. Si el motor gráfico del teléfono presenta incompatibilidades, prueba `--no-enable-impeller` como diagnóstico.

La configuración real y sus copias quedan fuera de Git. Las cuentas permanecen en Supabase Auth, no en el código fuente. El APK de CI no incorpora configuración. El acceso real solo se confirma después de la autenticación local y remota y de registrar la sesión.

## Instalación y ejecución (referencia del proyecto académico original)

1. Crear un proyecto Supabase dedicado. En SQL Editor ejecutar `supabase/migrations/202611240001_secureapp_access.sql` con el rol administrativo del proyecto. No añadir `secureapp_private` a los esquemas expuestos por la Data API.
2. Ejecutar `supabase/tests/permissions.sql`. Las diez columnas deben devolver `true`.
3. En Authentication, habilitar Email/Password, desactivar registros públicos y crear manualmente dos usuarios de prueba. No usar contraseñas reales reutilizadas ni datos biométricos.
4. En Settings/API Keys obtener Project URL y Publishable key (`sb_publishable_...`). Nunca usar la clave `sb_secret_...`, `service_role` ni la contraseña de PostgreSQL en Flutter.
5. Crear `secureapp.config.json` en la raíz del proyecto (Git lo ignora):

```json
{
  "SUPABASE_URL": "https://TU_PROYECTO.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_TU_CLAVE"
}
```

6. Desde la terminal de VS Code en la raíz del proyecto, ejecutar uno a uno:

```powershell
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter devices
flutter run --dart-define-from-file=secureapp.config.json
```

Sin configuración válida, el acceso permanece bloqueado. El ejemplo de configuración no es una conexión real. El teléfono debe tener huella o credencial registrada y conexión a internet. Android requiere reinstalar la aplicación después de los cambios nativos, no solo hot reload.

## Cómo funciona

- `AuthRepository` define el contrato de autenticación local.
- `BiometricAuthRepository` llama al diálogo del sistema y maneja cancelaciones, bloqueos y fallos.
- `AccountRepository` define el registro de acceso remoto.
- `SupabaseAccountRepository` autentica la cuenta por HTTPS y ejecuta una única función RPC; no conserva tokens en archivos ni consulta la tabla privada. Intenta revocar la sesión al terminar; el token de acceso puede conservar validez hasta su vencimiento si fue capturado.
- `AuthController` permite entrar solo después de ambos pasos. Al cerrar sesión o pasar a segundo plano fuera del diálogo biométrico, invalida el acceso local. Un resultado tardío no puede restaurar la sesión cancelada.
- La base de datos utiliza el identificador de usuario y de sesión extraídos del JWT validado por Supabase, no datos enviados por el cliente. Cada sesión registra una sola fila; el servidor asigna la fecha. La RPC no devuelve registros.

## Seguridad y alcance

La huella la comprueba el sistema operativo. `local_auth` no es una prueba criptográfica de biometría ante Supabase ni un segundo factor remoto. Una persona con credenciales válidas puede llamar a la RPC desde otro cliente: el registro significa que hubo una solicitud autenticada, no que el servidor haya verificado la huella. La pantalla principal es una confirmación local sin datos sensibles. Para datos privados futuros, añadir autorización en servidor y, si se requiere biometría verificable remotamente, diseñar autenticación con credenciales de clave pública/passkeys o MFA soportada por el servidor.

La tabla `secureapp_private.access_log` tiene RLS y no concede permisos de lectura ni escritura directa a `anon` o `authenticated`. El administrador autorizado de Supabase sí puede consultar/exportar los datos. Ningún sistema puede garantizar que datos visibles a un usuario no se copien. `FLAG_SECURE` bloquea capturas normales en Android, pero no garantiza protección frente a un dispositivo modificado, una cámara externa o la extracción de datos visibles. No agregar datos personales innecesarios. El botón de seguridad del dispositivo permite PIN/patrón o biometría según Android; no equivale a biometría obligatoria. Si la política exige huella exclusivamente, quitar esa alternativa y verificar modalidades disponibles.

## Validación

Pruebas unitarias incluidas: éxito, cancelación biométrica, fallo remoto, configuración ausente, acceso concurrente y resultado tardío, flujo HTTP simulado y claves no permitidas. Las pruebas HTTP usan datos de ejemplo. Las pruebas SQL comprueban los permisos; deben ejecutarse en el proyecto Supabase real. No se ha compilado ni probado en un teléfono desde el entorno de preparación. Verificar contraseña errónea, falta de internet, huella no registrada, cancelación, éxito, bloqueo al salir y que el SQL registre una fila por sesión. Usar dos cuentas de prueba para confirmar que ninguna puede descargar la auditoría.
