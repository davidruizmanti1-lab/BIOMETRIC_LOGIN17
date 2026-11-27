# Velero2H · Plan de escalabilidad V2.8

## Implementado
- Índice access_log(user_id, accessed_at desc) en Supabase; migración registrada 20261127010334. El índice cubre la FK y consultas de historial por usuario. No se borraron datos.
- Vista previa de galería decodificada con ancho máximo 1200 píxeles; zoom conserva imagen original. Se omiten filtros sin fotos instaladas. No cambia el origen de los recursos.
- Skill mobile-scalability, comprobaciones SQL y prueba de categorías.
- Mantiene autenticación, límites HTTP, cuotas BRISA y RLS.

## Siguiente fase (no implementada ni medida)
- Catálogo remoto: reutilizar el contrato web aprobado de properties + units, con cursor y límite 20; inventario real y permisos de lectura explícitos. No crear catálogos paralelos sin reconciliar datos.
- Solicitudes de reserva pendientes, aprobación humana, disponibilidad centralizada y transacciones idempotentes. Sin cobros automáticos.
- Pruebas de carga en staging: iniciar con 10, 50 y 100 usuarios simulados; no probar carga contra producción. Medir p95, errores, memoria y coste por consulta. Objetivos iniciales orientativos: p95 de catálogo <500 ms, errores <1%, cuadros fluidos en Infinix; calibrar con resultados reales.
- Retención de logs y limpieza por lotes: acordar plazo y política antes de borrar registros; separar seguridad de métricas.
- Imágenes remotas optimizadas mediante CDN, caché limitada, carga bajo demanda y manejo sin conexión. No incorporar datos de terceros sin revisión.
- Revisar pool de conexiones y capacidad de infraestructura solo cuando métricas lo justifiquen.

## Validación y reversión
El índice no cambia el contrato de la app; si causa problemas se puede retirar en una migración posterior tras revisar dependencias. Los registros y las tablas se conservan. Repetir advisors después de actividad real y verificar EXPLAIN con datos sintéticos en staging. La CI no sustituye pruebas en Android físico. No se han ejecutado pruebas de carga ni inferencia real Groq.
