# Velero2H Mobile 2.3 · Aqua Luxury

Rama de desarrollo: velero2h-mobile-aqua. Mantiene el inicio de sesión original y la RPC de acceso. No modifica producción web ni las cuentas existentes.

## Windows / VS Code / Android
Con la carpeta del proyecto abierta y sin cambios locales pendientes:
```powershell
git status
git fetch entrega
git switch --track entrega/velero2h-mobile-aqua
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter devices
flutter run --dart-define-from-file=secureapp.config.json
```
Si la rama local ya existe: git switch velero2h-mobile-aqua; git pull --ff-only entrega velero2h-mobile-aqua.
Si hay cambios locales, guardarlos en un commit o copia de seguridad antes de cambiar de rama. No ejecutar reset --hard.
El archivo secureapp.config.json debe contener la URL y la clave PUBLICABLE del Supabase original; está excluido de Git. No crear cuentas duplicadas. No usar claves secretas en Flutter.
Para un APK local: flutter build apk --debug --dart-define-from-file=secureapp.config.json.
Android: desbloquear teléfono, activar opciones de desarrollador y depuración USB, usar cable de datos y aceptar la huella de la computadora. Si hay varios dispositivos: flutter run -d ID_ANDROID --dart-define-from-file=secureapp.config.json.
En flutter run: r actualiza widgets; R reinicia Dart. Cambios de dependencias, recursos o Android requieren detener y ejecutar de nuevo.

## Fotos
Cuatro fotografías verificadas del establecimiento y logo incluidos. Las 16 fotos adicionales del propietario están en el ZIP V2.2. Ejecutar scripts/Importar-Fotos.ps1 con la ruta al ZIP para copiar únicamente los WebP optimizados, sin reemplazar código. Reconstruir la app después. No se asignan a unidades reservables ni se anuncian capacidades, precios ni amenidades no verificadas.

## Alcance
FAQ local de BRISA y clasificación semántica opcional mediante IA, catálogo local, navegación por pestañas y botones, mapa OSM en línea y rutas externas, GPS con permiso, itinerarios por reglas y división de gastos local durante la sesión. Sin mapas offline descargables, reservas confirmadas, pagos, reseñas verificadas ni almacenamiento de itinerarios tras cerrar sesión. La política existente cierra el acceso al pasar a segundo plano. El mapa puede transmitir las teselas consultadas al proveedor.
La biometría local no constituye prueba criptográfica ante Supabase. Los JWT pueden seguir válidos hasta expirar. La compilación y prueba física deben verificarse; no afirmar seguridad garantizada.

## Criterios UI/UX
Paleta aguamarina, contraste de texto, una acción principal por pantalla, controles táctiles, galería con paginación y etiquetas semánticas, navegación fija, manejo explícito de errores y ausencia de precios inventados. Verificar en el Infinix con teclado abierto y texto ampliado.

## Activar IA opcional
En el Supabase original, ejecutar la migración de cuota y desplegar la función brisa. Configurar BRISA_AI_API_KEY y BRISA_AI_MODEL como secretos de la función, nunca en Flutter. Añadir VELERO2H_BRISA_AI=true a secureapp.config.json y reconstruir. El modelo solo selecciona un identificador de respuesta; no inventa inventario ni precios. Si el servicio falla, la FAQ local sigue disponible. La pregunta general se envía al proveedor si se activa la opción; no enviar datos personales. Los límites se aplican por cuenta. No se ha desplegado ni probado la función real.

## V2.4
CI anterior: Dart 3.10.0-290.4.beta no satisface >=3.10.0. Se cambia el SDK fijado a 3.50.1, sugerido por el propio solucionador. Comprobar las nuevas ejecuciones de Actions; la corrección no equivale a una compilación aprobada. Logo original del propietario, optimizado a WebP, incorporado en login, arranque, encabezado e icono Android. La galería incluye ampliación y el login permite reintentar la detección biométrica. El flujo de acceso remoto se conserva. Los datos de prueba y la configuración local de Supabase no se incluyen en Git.

## V2.5
La CI V2.4 aprobó 16 pruebas, pero AGP 9.1.0 bloqueó assembleDebug. Se cambia a AGP 9.1.1 sin desactivar validaciones. Gradle 9.3.1 conserva una advertencia de futura incompatibilidad; actualizar por separado tras comprobar compatibilidad. BRISA admite hasta dos temas y conserva su guía local. La IA en línea requiere despliegue en Supabase. Los avisos de Material de Flutter 3.50.1 quedan pendientes de una migración de dependencias verificada.

BRISA muestra historial paginado de hasta 12 consultas por sesión, respuesta local inmediata, estado de IA y degradación explícita. Guía: [Activación de BRISA](BRISA_ACTIVACION.md).

## V2.6 Secure Luxury
Límite de 64 KiB por respuesta HTTP del cliente, cancelación de consulta BRISA al cerrar sesión, rechazo de respuestas tardías, validación de host HTTPS exacto y control de primer plano antes del acceso remoto. Nueva migración de cuota con sesión registrada, revocación y vencimiento a 30 minutos (requiere despliegue). Se conserva biometría, FLAG_SECURE, prohibición de HTTP y configuración fuera de Git. No se han ejecutado pruebas físicas ni desplegado migraciones desde ChatGPT.

## V2.6.1 — corrección crítica
La ejecución 45918190349 informó 101 incidencias (incluidos avisos) y falló en análisis, no en ensamblado. La edición del patrón de host dejó una cadena incompleta y duplicó parte de SupabaseAccountRepository. Se reconstruyó una sola clase válida conservando el límite HTTP, revisión de sesión y cierre remoto. Nueva prueba de cancelación durante autenticación. No se ha confirmado el resultado de la nueva CI ni el despliegue de Supabase.

## V2.7 — biometría y accesibilidad
La CI V2.6.1 terminó correctamente, incluido APK. V2.7 separa las consultas de soporte y enrolamiento; tolera hasta 2 segundos de transición del diálogo biométrico al estado resumed después de una verificación local exitosa. Cerrar sesión invalida la espera. No se elimina la autenticación local ni la comprobación Supabase. El login permite desplazamiento solo cuando el contenido no cabe, para evitar pérdida de botones con teclado o texto ampliado. Tres nuevas pruebas de controlador simuladas. Falta prueba física.
BRISA está desplegada en el proyecto velero2hcol con JWT. Las claves del proveedor se configuran en Edge Functions > Secrets. No se confirma inferencia Groq hasta recibir una respuesta real. El APK de CI no lleva configuración de Supabase; instalar desde VS Code con secureapp.config.json. Comprueba que su URL corresponde al proyecto xsbrwkxptxqnfdzvygwl antes de iniciar sesión.

## V2.7.1 — acceso y diagnóstico físico
La detección biométrica es orientativa, no una condición que sustituya al diálogo de Android. El usuario puede iniciar la verificación nativa aunque la detección previa sea negativa; una cancelación o un resultado fallido nunca habilita acceso remoto. Se añaden mensajes de estado en login, una prueba de regresión y un diagnóstico opcional de Infinix sin instalar. Ejecutar scripts/Verificar-Infinix.ps1 -SoloDiagnostico para comprobar configuración, Flutter y dispositivos físicos sin compilar ni instalar. No se muestran claves. La compilación CI sin configuración no permite iniciar sesión; reconstruir localmente con secureapp.config.json. La V2.7 original superó análisis y pruebas; comprobar por separado la compilación de este parche. No se han realizado pruebas físicas.

## V2.8 — escalabilidad
Índice de acceso aplicado en Supabase, comprobaciones SQL y skill de escalabilidad. Galería oculta categorías sin recursos y reduce memoria de vista previa, sin reducir el original al ampliar. Ver docs/SCALABILITY.md. Compilación nueva pendiente; no se garantiza capacidad concurrente sin pruebas.

## V2.8.1 — acceso en Infinix
Tras instalación V2.8 el usuario informa que los toques y el teclado no responden. El login se simplifica a una única pantalla con nodos de foco estables, campos permanentes y desplazamiento manual; se evita reconstruir la estructura del formulario cuando aparece el teclado. Se conserva autenticación nativa y Supabase. Se añade prueba de interacción simulada con teclado y autenticación. La causa física no está confirmada; revisar también debugger, registros Android y modo de renderizado si persiste. No se deshabilita FLAG_SECURE.

## V2.8.2 — diagnóstico de acceso
Se distinguen errores de cuenta conocidos de rechazos HTTP de configuración, sin exponer respuestas crudas. El script Diagnosticar-Supabase.ps1 consulta únicamente Auth settings con la clave publicable; no envía contraseñas ni autentica al usuario. El acceso real requiere biometría física, credenciales válidas y registro RPC exitoso. No se modificaron cuentas ni permisos.

## V2.8.3 — configuración del proyecto
Se confirmó que el equipo local apuntaba a un proyecto Supabase distinto. El punto de entrada de producción fija el host esperado y rechaza configuraciones de otro proyecto antes de enviar credenciales. El script Configurar-Supabase.ps1 comprueba Auth antes de guardar URL y clave publicable; conserva las otras opciones locales y una copia ignorada por Git. Se añade ejemplo sin claves y prueba de aislamiento. No se cambian usuarios, permisos ni migraciones. El acceso físico todavía debe verificarse.
