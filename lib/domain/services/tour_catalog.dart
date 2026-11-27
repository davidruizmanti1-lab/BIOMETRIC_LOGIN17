import 'travel_tools.dart';

class VeleroTour {
  final String id, title, category, hours;
  final int price;
  final bool perPerson;
  final List<String> includes;
  final String? optional;

  const VeleroTour({
    required this.id,
    required this.title,
    required this.category,
    required this.hours,
    required this.price,
    required this.includes,
    this.perPerson = true,
    this.optional,
  });

  String get asset => 'assets/images/velero/tour_$id.webp';
  String get rate => TravelTools.cop(price) + (perPerson ? ' / persona' : ' (unidad de cobro por confirmar)');
  String get description {
    final extras = optional;
    return '$title\n$rate\nHorario anunciado: $hours.\nIncluye: ${includes.join(', ')}.'
        + (extras == null ? '' : '\nOpcional: $extras.');
  }
}

abstract final class TourCatalog {
  static const confirmation = 'Tarifas y horarios del material suministrado. Confirma vigencia, cupos y condiciones con el equipo antes de reservar.';
  static const all = <VeleroTour>[
    VeleroTour(
      id: 'bahia_concha', title: 'Bahía Concha · Tayrona',
      category: 'Naturaleza', hours: '09:00–17:30', price: 130000,
      perPerson: false,
      includes: ['Transporte', 'Guía', 'Seguro', 'Entrada', 'Almuerzo'],
      optional: 'Snorkel por $35.000 COP, según anuncio',
    ),
    VeleroTour(
      id: 'velero_concha', title: 'Bahía Concha en velero',
      category: 'Navegación', hours: '10:00–17:00', price: 260000,
      includes: ['Transporte climatizado', 'Entrada al parque', 'Seguro', 'Snorkel',
        'Una bebida', 'Fruta', 'Almuerzo', 'Paddle board'],
    ),
    VeleroTour(
      id: 'katamaran', title: 'Tour Bahía Katamaran',
      category: 'Navegación', hours: '10:00–16:30', price: 160000,
      includes: ['Transporte marítimo', 'Seguro', 'Guía profesional', 'Cóctel de bienvenida',
        'Recorrido por las bahías', 'Pasadía en Playa Inca Inca', 'Almuerzo', 'Snorkel o kayak'],
      optional: 'Ingreso al acuario; valor por consultar',
    ),
    VeleroTour(
      id: 'barranquilla', title: 'Barranquilla y Puerto Mocho',
      category: 'Cultura', hours: '08:45–17:30', price: 160000,
      includes: ['Transporte climatizado', 'Guía profesional', 'Seguro de viaje', 'Mirador',
        'Malecón del Río', 'Ventana al Mundo', 'Aleta del Tiburón', 'Estación de Las Flores',
        'Tren a Puerto Mocho', 'Pasadía en Puerto Mocho', 'Almuerzo'],
    ),
  ];

  static String normalize(String text) {
    var value = text.toLowerCase();
    for (final pair in ['áa', 'ée', 'íi', 'óo', 'úu', 'üu', 'ñn']) {
      value = value.replaceAll(pair[0], pair[1]);
    }
    return value;
  }

  static List<VeleroTour> matching(String question) {
    final q = normalize(question);
    final matches = <VeleroTour>[];
    if (q.contains('concha')) {
      if (q.contains('velero')) {
        matches.add(all[1]);
      } else if (q.contains('tayrona') && !q.contains('compar')) {
        matches.add(all[0]);
      } else {
        matches.addAll(all.take(2));
      }
    }
    if (q.contains('katamaran') || q.contains('catamaran') || q.contains('inca inca')) {
      matches.add(all[2]);
    }
    if (q.contains('barranquilla') || q.contains('puerto mocho')) {
      matches.add(all[3]);
    }
    return matches;
  }

  static String get summary => all.map((t) => '${t.title}: ${t.rate} · ${t.hours}').join('\n')
      + '\n\n' + confirmation;

  static String? answer(String question) {
    final matches = matching(question);
    if (matches.isEmpty) return null;
    return matches.map((t) => t.description).join('\n\n') + '\n\n' + confirmation;
  }
}
