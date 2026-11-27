---
name: android-release-qa
description: Diagnostica compilación Flutter Android y prueba el Infinix con evidencia reproducible.
---
# Android QA
- Lee primero la última ejecución de Actions y el primer error causal.
- Revisa versiones reales de Flutter, Dart, Java, AGP y Gradle; evita saltar validaciones.
- Ejecuta flutter pub get, flutter analyze, flutter test y flutter build apk --debug.
- Verifica flutter devices --machine y selecciona el Android físico explícitamente.
- Comprueba acceso, cancelación biométrica, teclado, galería, BRISA, GPS y segundo plano.
- Registra resultado por dispositivo y versión. No confundas un APK sin configuración con una app lista para producción.
- Nunca distribuyas builds firmados con clave debug como release comercial.
