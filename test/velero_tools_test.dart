import 'package:flutter_test/flutter_test.dart';
import 'package:biometric_login/domain/services/brisa_faq.dart';
import 'package:biometric_login/domain/services/travel_tools.dart';
import 'package:biometric_login/domain/services/velero_gallery.dart';

void main() {
  test('Los gastos se reparten sin perder pesos', () {
    expect(TravelTools.split(10001, 3), [3334, 3334, 3333]);
    expect(TravelTools.cop(1250000), r'$1.250.000 COP');
    expect(() => TravelTools.split(100, 0), throwsArgumentError);
  });
  test('El itinerario respeta duración y preferencia', () {
    final plan = TravelTools.plan(TravelInterest.cultura, 5);
    expect(plan.length, 5);
    expect(plan.first.title, 'Cultura samaria');
    expect(() => TravelTools.plan(TravelInterest.playa, 0), throwsArgumentError);
  });
  test('BRISA rechaza datos personales y no inventa precios', () {
    expect(BrisaFaq.safe('cliente@ejemplo.com'), isFalse);
    expect(BrisaFaq.answer('precio'), contains('cotización'));
    expect(BrisaFaq.answer('astronomía'), BrisaFaq.fallback);
    expect(BrisaFaq.answer('consulta', topic: 'otro'), BrisaFaq.fallback);
  });
  test('La galería usa únicamente recursos instalados', () {
    final assets = VeleroGallery.website.map((p) => p.asset).toSet();
    expect(VeleroGallery.available(assets, PhotoCategory.all).length, 4);
    expect(VeleroGallery.available(assets, PhotoCategory.bathroom), isEmpty);
    assets.add(VeleroGallery.owner[2].asset);
    expect(VeleroGallery.available(assets, PhotoCategory.bathroom).length, 1);
  });
}
