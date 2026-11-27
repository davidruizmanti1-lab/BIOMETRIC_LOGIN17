---
name: regression-qa
description: Previene regresiones de interfaz, autenticación, lógica turística y seguridad de Velero2H.
---
# Pruebas de regresión
- Reproduce el error mediante una prueba antes de corregir cuando sea viable.
- Cubre casos válidos, límites, cancelaciones y fallos de red.
- Prueba pantallas pequeñas, teclado, texto ampliado y paginación sin scroll general.
- No reduzcas aserciones para hacer pasar pruebas. Usa mocks identificados como tales.
- Reporta resultados de CI por commit y separa pruebas simuladas de pruebas físicas.

## Ediciones seguras de código
- Evita sustituciones textuales que interpreten caracteres especiales. Al modificar expresiones regulares y cadenas Dart, conserva literalmente el contenido.
- Verifica por lectura del archivo completo que no haya funciones duplicadas ni fragmentos añadidos fuera de la clase.
- Ante una CI roja, prioriza el primer error causal; no publiques otra feature sobre una sintaxis rota.
