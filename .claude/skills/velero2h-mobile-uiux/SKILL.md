---
name: velero2h-mobile-uiux
description: Revisa y mejora pantallas Flutter de Velero2H con identidad Aqua Luxury, navegación sin scroll vertical general, accesibilidad y pruebas Android.
---

# Velero2H mobile UI/UX

1. Lee primero lib/core/velero_theme.dart, el widget a cambiar y docs/VELERO2H_MOBILE.md.
2. Usa la paleta aqua, ocean, ivory y gold. Texto sobre turquesa claro debe ser oscuro; botones oscuros con texto blanco.
3. Usa una acción primaria por pantalla, controles táctiles de 48 dp, jerarquía clara y espacios consistentes. No uses decoración que compita con las fotografías.
4. Conserva navegación fija. Divide contenido extenso mediante botones/páginas; adapta el formulario al teclado y comprueba tamaños pequeños y texto ampliado.
5. Fotografía real: no atribuyas capacidad, servicios, tarifa ni disponibilidad a una unidad no confirmada. No incorpores fotos generadas como inventario.
6. No modifiques AuthController ni el flujo biométrico sin pruebas. No copies credenciales, JWT o datos privados al código. Mantén los permisos GPS bajo acción del usuario.
7. BRISA solo responde hechos verificados; ninguna confirmación automática, pago ni precio inventado.
8. Ejecuta flutter analyze, flutter test y compilación Android. Prueba en dispositivo físico las pantallas y estados de error. Informa qué pasó y qué no se comprobó; nunca declares una prueba exitosa sin evidencia.
