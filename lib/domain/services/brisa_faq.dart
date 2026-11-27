// Respuestas basadas en la información publicada por Velero2H.
abstract final class BrisaFaq {
  static const topics = <(String, String, List<String>)>[
    ('reservar', 'Elige alojamiento y fechas y consulta al equipo. Solo la confirmación humana aparta fechas.', ['reserv','apartar','solicitud']),
    ('precios', 'El valor depende de fechas, duración y personas. El equipo prepara la cotización.', ['precio','tarifa','cuesta','valor','cotiz','costo']),
    ('disponibilidad', 'No conozco el cupo en tiempo real. Consulta al equipo con tus fechas y número de personas.', ['disponib','cupo','fecha','ocupado']),
    ('pago', 'Las condiciones se acuerdan con el equipo al confirmar. El sitio no ofrece compra inmediata ni pagos en línea.', ['pago','pagar','pse','tarjeta','anticipo']),
    ('alojamientos', 'Ofrecemos habitaciones, apartaestudios y apartamentos por días o semanas en Santa Marta. Confirma la unidad y servicios con el equipo.', ['habitacion','apartamento','apartaestudio','alojamiento','tipo','aire']),
    ('ubicacion', 'Tacaloa Beach es un establecimiento en Santa Marta. El equipo comparte la ubicación exacta de cada alojamiento.', ['ubicacion','direccion','donde','tacaloa','mapa']),
    ('tours', 'Podemos orientarte sobre Tayrona, bahías y Sierra Nevada. Consulta horarios, valores y cupos con el equipo.', ['tour','tayrona','paseo','sierra','excursion']),
    ('fotos', 'La galería contiene fotografías reales. No confirma la capacidad ni disponibilidad de una unidad específica.', ['foto','imagen','galeria','cocina','bano']),
    ('persona', 'En velero2h.lat puedes contactar al equipo. BRISA no envía mensajes por ti.', ['whatsapp','contacto','asesor','persona','humano']),
  ];
  static const fallback = 'No tengo una respuesta verificada. Consulta al equipo en velero2h.lat.';
  static bool safe(String q) => q.trim().isNotEmpty && q.length <= 300 &&
    !q.contains('@') && !RegExp(r'(?:\d[\s().+-]*){7,}').hasMatch(q);

  static String answer(String q, {String? topic}) {
    if (!safe(q)) return 'Escribe una pregunta general sin datos personales.';
    if (topic != null) {
      for (final item in topics) { if (item.$1 == topic) return item.$2; }
      return fallback;
    }
    var normalized = q.toLowerCase();
    for (final pair in ['áa','ée','íi','óo','úu','üu','ñn']) { normalized = normalized.replaceAll(pair[0], pair[1]); }
    final words = normalized.split(RegExp(r'[^a-z0-9]+'));
    var score = 0;
    var reply = fallback;
    for (final item in topics) {
      final current = item.$3.where((key) => words.any((word) => word.startsWith(key))).length;
      if (current > score) { score = current; reply = item.$2; }
    }
    return reply;
  }
}
