enum TravelInterest { playa, cultura, naturaleza }

class TravelDay {
  final String title, morning, afternoon;
  const TravelDay(this.title, this.morning, this.afternoon);
}

abstract final class TravelTools {
  static List<TravelDay> plan(TravelInterest interest, int days) {
    if (days < 1 || days > 5) throw ArgumentError('Duración inválida');
    const beach = TravelDay('Día de playa', 'El Rodadero', 'Paseo por la costa');
    const culture = TravelDay('Cultura samaria', 'Centro histórico', 'Bahía de Santa Marta');
    const nature = TravelDay('Naturaleza', 'Consultar acceso al Tayrona', 'Tiempo libre');
    const rest = TravelDay('Descubre a tu ritmo', 'Consultar paseo por las bahías', 'Gastronomía local');
    const last = TravelDay('Sin afán', 'Desayuno y paseo cercano', 'Preparar el regreso');
    final first = switch(interest) { TravelInterest.playa => beach, TravelInterest.cultura => culture, TravelInterest.naturaleza => nature };
    return <TravelDay>{first, beach, culture, nature, rest, last}.take(days).toList();
  }

  static List<int> split(int total, int people) {
    if (total < 0 || people < 1 || people > 20) throw ArgumentError('División inválida');
    return List.generate(people, (i) => total ~/ people + (i < total % people ? 1 : 0));
  }

  static String cop(int n) => '\$'+n.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')+' COP';
}
