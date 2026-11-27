import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biometric_login/core/velero_theme.dart';
import 'package:biometric_login/presentation/widgets/velero_brand.dart';
import 'package:biometric_login/presentation/screens/home_screen.dart';

void main() {
  testWidgets('Logo oficial y catálogo a tamaño de teléfono', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var brisa = false;
    await tester.pumpWidget(MaterialApp(theme: VeleroTheme.light, home: Scaffold(
      appBar: AppBar(title: const VeleroBrand(size: 44)),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(12),
        child: CatalogScreen(onBrisa: () => brisa = true))),
    )));
    await tester.pumpAndSettle();
    expect(find.byType(VeleroBrand), findsOneWidget);
    expect(find.text('Consultar alojamiento y fechas'), findsOneWidget);
    await tester.tap(find.byTooltip('Foto siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preguntar a BRISA'));
    expect(brisa, isTrue);
    expect(tester.takeException(), isNull);
  });
}
