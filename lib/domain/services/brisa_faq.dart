import 'tour_catalog.dart';

// Respuestas basadas en la información publicada por Velero2H.
abstract final class BrisaFaq {
  static const topics = <(String, String, List<String>)>[
    ('reservar', 'Elige alojamiento y fechas y consulta al equipo. Solo la confirmación humana aparta fechas.', ['reserv','apartar','solicitud']),
    ('precios', 'El valor depende de fechas, duración y personas. El equipo prepara la cotización.', ['precio','tarifa','cuesta','valor','cotiz','costo']),
    ('disponibilidad', 'No conozco el cupo en tiempo real. Consulta al equipo con tus fechas y número de personas.', ['disponib','cupo','fecha','ocupado']),
    ('pago', 'Las condiciones se acuerdan con el equipo al confirmar. El sitio no ofrece compra inmediata ni pagos en línea.', ['pago','pagar','pse','tarjeta','anticipo']),
    ('alojamientos', 'Ofrecemos habitaciones, apartaestudios y apartamentos por días o semanas en Santa Marta. Confirma la unidad y servicios con el equipo.', ['habitacion','apartamento','apartaestudio','alojamiento','tipo']),
    ('ubicacion', 'Tacaloa Beach es un establecimiento en Santa Marta. El equipo comparte la ubicación exacta de cada alojamiento.', ['ubicacion','direccion','donde','tacaloa','mapa']),
    ('tours', 'Podemos orientarte sobre Tayrona, bahías y Sierra Nevada. Consulta horarios, valores y cupos con el equipo.', ['tour','tayrona','paseo','sierra','excursion']),
    ('fotos', 'La galería contiene fotografías reales. No confirma la capacidad ni disponibilidad de una unidad específica.', ['foto','imagen','galeria']),
    ('servicios', 'Las fotos muestran aire acondicionado, televisor, baños y algunas cocinas con utensilios. Confirma cuáles incluye la unidad que te interesa con el equipo.', ['aire','acondicionado','televisor','cocina','utensilio','nevera','bano','servicio']),
    ('persona', 'En velero2h.lat puedes contactar al equipo. BRISA no envía mensajes por ti.', ['whatsapp','contacto','asesor','persona','humano']),
  ];
  static const fallback = 'No tengo una respuesta verificada. Consulta al equipo en velero2h.lat.';
  static const privacy = 'Escribe una pregunta general sin datos personales.';

  static bool safe(String q) => q.trim().isNotEmpty && q.length <= 300 &&
      !q.contains('@') && !RegExp(r'(?:\d[\s().+-]*){7,}').hasMatch(q);

  static String _normalize(String text) {
    var result = text.toLowerCase();
    for (final pair in ['áa','ée','íi','óo','úu','üu','ñn']) {
      result = result.replaceAll(pair[0], pair[1]);
    }
    return result;
  }

  // El modelo elige temas permitidos, nunca inventa la respuesta final.
  static List<String> validTopics(String? raw) {
    if (raw == null) return [];
    final allowed = topics.map((item) => item.$1).toSet();
    return raw.split(',').map((item) => item.trim()).where(allowed.contains)
        .toSet().take(2).toList(growable: false);
  }

  static List<String> localTopics(String q) {
    if (!safe(q)) return [];
    final words = _normalize(q).split(RegExp(r'[^a-z0-9]+'));
    final ranked = <(String, int, int)>[];
    for (var i = 0; i < topics.length; i++) {
      final item = topics[i];
      final score = item.$3.where((key) => words.any((word) => word.startsWith(key))).length;
      if (score > 0) ranked.add((item.$1, score, i));
    }
    ranked.sort((a, b) {
      final score = b.$2.compareTo(a.$2);
      return score != 0 ? score : a.$3.compareTo(b.$3);
    });
    return ranked.take(2).map((item) => item.$1).toList(growable: false);
  }

  static String answer(String q, {String? topic}) {
    if (!safe(q)) return privacy;
    final catalogAnswer = TourCatalog.answer(q);
    if (catalogAnswer != null) return catalogAnswer;
    final selected = topic == null ? localTopics(q) : validTopics(topic);
    if (selected.isEmpty) return fallback;
    return selected.map((id) => id == 'tours' ? TourCatalog.summary : topics.firstWhere((item) => item.$1 == id).$2).join('\n\n');
  }
}
