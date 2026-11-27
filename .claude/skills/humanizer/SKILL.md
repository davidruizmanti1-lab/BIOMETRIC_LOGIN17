---
name: humanizer
description: Simplifica Dart, documentación y comentarios de Velero2H para mejorar legibilidad y mantenimiento sin alterar comportamiento ni ocultar errores.
---

# Humanizer de código limpio

- Lee el archivo, sus llamadas y sus pruebas antes de editar. Prioriza cambios pequeños.
- Usa nombres descriptivos, retornos tempranos, funciones con una responsabilidad y tipos claros.
- Extrae lógica repetida solo si mejora la lectura. Evita patrones y dependencias innecesarios.
- Comentarios breves en español: explica por qué, no repitas el código.
- No desactives análisis, pruebas ni seguridad para obtener resultados verdes.
- No añadas errores artificiales ni prometas evadir detectores. El autor debe comprender y poder explicar sus cambios.
- Ejecuta dart format sobre los archivos modificados, flutter analyze, flutter test y la compilación Android.
- Resume cambios, pruebas reales y limitaciones. No inventes resultados.

- En el catálogo usa una única fuente de datos para la interfaz y BRISA; no dupliques tarifas en widgets. Nombres de componentes claros, sin abstracciones de una sola línea innecesarias.
