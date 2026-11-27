import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:biometric_login/presentation/controllers/auth_controller.dart';
import 'package:biometric_login/presentation/screens/login_screen.dart';
import 'package:biometric_login/domain/entities/auth_result.dart';
import 'access_controller_test.dart' show DeviceAuth, Accounts;

void main() {
  testWidgets('Correo, teclado y biometría en una pantalla estable', (tester) async {
    final device = DeviceAuth();
    final accounts = Accounts();
    final auth = AuthController(device, accounts);
    addTearDown(auth.dispose);
    await auth.init();
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth, child: const MaterialApp(home: LoginScreen()),
    ));
    await tester.pumpAndSettle();
    final email = find.byKey(const ValueKey('login-email'));
    final password = find.byKey(const ValueKey('login-password'));
    final button = find.byKey(const ValueKey('login-biometric'));
    await tester.tap(email);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    tester.view.viewInsets = const FakeViewPadding(bottom: 250);
    await tester.pumpAndSettle();
    await tester.enterText(email, 'student@example.com');
    await tester.ensureVisible(password);
    await tester.enterText(password, 'test-only');
    tester.view.viewInsets = const FakeViewPadding();
    await tester.pumpAndSettle();
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(device.calls, 1);
    expect(accounts.calls, 1);
    expect(auth.isAuthenticated, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sin credenciales o biometría válida no concede acceso', (tester) async {
    final device = DeviceAuth();
    final accounts = Accounts();
    final auth = AuthController(device, accounts);
    addTearDown(auth.dispose);
    await auth.init();
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: auth, child: const MaterialApp(home: LoginScreen()),
    ));
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('login-biometric'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(device.calls, 0);
    await tester.enterText(find.byKey(const ValueKey('login-email')), 'student@example.com');
    await tester.enterText(find.byKey(const ValueKey('login-password')), 'test-only');
    device.result = const AuthResult(AuthStatus.cancelled, 'Cancelado');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(device.calls, 1);
    expect(accounts.calls, 0);
    expect(auth.isAuthenticated, isFalse);
  });
}
