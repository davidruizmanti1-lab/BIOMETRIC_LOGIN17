---
name: mobile-scalability
description: Escala Velero2H Flutter y Supabase con mediciones, carga paginada, índices, límites de consumo y compatibilidad de Android.
---

# Escalabilidad Velero2H

1. Lee primero pubspec, el módulo afectado y docs/SCALABILITY.md. Conserva contratos existentes, biometría, MODE B y la separación web/móvil.
2. Mide antes de cambiar: tiempo de arranque, cuadros lentos, memoria en teléfono físico, p50/p95 de HTTP y consultas SQL, errores y consumo de IA. Registra tamaño de muestra.
3. En Flutter usa carga bajo demanda, imágenes redimensionadas para la vista y original en zoom; evita trabajo costoso en build y peticiones duplicadas. No bloquees la interfaz con I/O.
4. Para catálogos remotos usa paginación por cursor, proyección de columnas, límites explícitos e índices acordes al filtro y orden. No descargues tablas completas. No inventes inventario, precio ni disponibilidad.
5. En PostgreSQL revisa advisors y EXPLAIN; prueba cambios en entorno de pruebas con datos sintéticos. RLS y grants son obligatorios; no uses service_role en clientes. No borres índices por una estadística inicial de uso cero.
6. En BRISA conserva cuotas, tiempos máximos y fallback local. No reintentes peticiones de pago o IA sin idempotencia y presupuesto. No guardes conversaciones sensibles sin consentimiento.
7. Mantén migraciones versionadas, plan de rollback y compatibilidad con la app instalada. No cambies recursos de producción ajenos al módulo.
8. Ejecuta flutter analyze, flutter test y APK. Prueba Infinix y carga controlada en staging. No declares capacidad de usuarios concurrentes sin medición ni contrates infraestructura sin autorización.

- Catálogo local con modelos tipados y recursos opcionales. Carga imágenes bajo demanda con cacheWidth; no mantengas el mapa activo fuera de su pestaña. Para ampliar el catálogo usa un repositorio paginado, sin cambiar el contrato de precios ni la aprobación humana.
