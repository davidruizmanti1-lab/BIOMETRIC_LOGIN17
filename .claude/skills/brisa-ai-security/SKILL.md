---
name: brisa-ai-security
description: Mejora BRISA con respuestas autorizadas, privacidad, límites de consumo y degradación segura.
---
# BRISA
- Usa únicamente hechos del catálogo aprobado y no inventes tarifas ni cupos.
- Trata entrada y salida del modelo como datos no confiables; valida temas contra lista cerrada.
- No envíes contraseñas, contactos, tokens ni secretos al modelo. Los filtros de texto son parciales; informa al usuario.
- Verifica JWT, registro de sesión, cuotas, vencimiento y revocación del lado servidor.
- Prueba 401, 429, 503, timeout, salida inválida, datos personales y sesión cerrada.
- Mantén respuesta local; diferencia IA real de fallback. No ejecutes acciones financieras o de reserva.
- Comprueba el despliegue y realiza una prueba con usuario autorizado antes de declarar IA funcional.
