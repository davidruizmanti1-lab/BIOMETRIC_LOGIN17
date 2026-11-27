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
