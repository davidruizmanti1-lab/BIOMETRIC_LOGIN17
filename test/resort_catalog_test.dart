import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biometric_login/domain/services/tour_catalog.dart';
import 'package:biometric_login/domain/services/brisa_faq.dart';
import 'package:biometric_login/domain/services/velero_gallery.dart';
import 'package:biometric_login/presentation/screens/tours_screen.dart';

void main() {
  test('Cuatro tours, precios y unidades del material entregado', () {
    expect(TourCatalog.all.map((t) => t.price), [130000, 260000, 160000, 160000]);
    expect(TourCatalog.all.first.perPerson, isFalse);
    expect(TourCatalog.all.map((t) => t.id).toSet().length, 4);
    expect(TourCatalog.all[1].includes, contains('Paddle board'));
  });
  test('BRISA distingue Concha en velero y Tayrona sin inventar cupos', () {
    expect(BrisaFaq.answer('¿Qué incluye Bahía Concha?'), contains('260.000'));
    expect(BrisaFaq.answer('Bahía Concha en velero', topic: 'precios'), contains('260.000'));
    expect(BrisaFaq.answer('Bahía Concha Tayrona'), contains('130.000'));
    expect(BrisaFaq.answer('¿Cuánto cuesta el Katamaran?'), contains('160.000'));
    expect(BrisaFaq.answer('¿Qué tours ofrecen?'), contains('Confirma vigencia'));
    expect(BrisaFaq.answer('Barranquilla cliente@example.com'), BrisaFaq.privacy);
  });
  test('Diez fotos nuevas organizadas y solo recursos instalados', () {
    final photos = VeleroGallery.resort;
    expect(photos.length, 10);
    final installed = photos.map((p) => p.asset).toSet();
    expect(VeleroGallery.available(installed, PhotoCategory.pool).length, 1);
    expect(VeleroGallery.available(installed, PhotoCategory.balcony).length, 3);
    expect(VeleroGallery.available({}, PhotoCategory.all), isEmpty);
  });
  testWidgets('Tours funciona sin carteles y prepara pregunta para BRISA', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? question;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: ToursScreen(onBrisa: (q) => question = q))));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ver experiencia').first);
    await tester.tap(find.text('Ver experiencia').first);
    await tester.pumpAndSettle();
    expect(find.text('Qué incluye'), findsOneWidget);
    final button = find.text('Consultar con BRISA');
    await tester.scrollUntilVisible(button, 160, scrollable: find.byType(Scrollable).last);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(question, contains('Bahía Concha'));
    expect(tester.takeException(), isNull);
  });
}
