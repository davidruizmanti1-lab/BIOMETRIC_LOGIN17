import 'dart:async';

import 'package:biometric_login/domain/entities/auth_result.dart';
import 'package:biometric_login/domain/repositories/account_repository.dart';
import 'package:biometric_login/domain/repositories/auth_repository.dart';
import 'package:biometric_login/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class DeviceAuth implements AuthRepository {
  AuthResult result = const AuthResult(AuthStatus.success);
  int calls = 0;
  bool supportError = false;
  bool enrolled = true;
  void Function()? onAuthenticate;

  @override
  Future<bool> isDeviceSupported() async {
    if (supportError) throw StateError('Sensor temporalmente no disponible');
    return true;
  }

  @override
  Future<bool> hasEnrolledBiometrics() async => enrolled;

  @override
  Future<AuthResult> authenticate({required bool biometricOnly}) async {
    calls++;
    onAuthenticate?.call();
    return result;
  }
}

class Accounts implements AccountRepository {
  @override
  bool isConfigured = true;
  int calls = 0;
  AccountException? failure;
  Completer<void>? pending;

  @override
  Future<void> registerAccess({required String email, required String password}) async {
    calls++;
    if (failure != null) throw failure!;
    if (pending != null) await pending!.future;
  }
}

void main() {
  late DeviceAuth device;
  late Accounts accounts;
  late AuthController controller;

  setUp(() async {
    device = DeviceAuth();
    accounts = Accounts();
    controller = AuthController(device, accounts);
    await controller.init();
  });

  tearDown(() => controller.dispose());

  Future<bool> login() => controller.login(
    email: 'student@example.com',
    password: 'test-only',
    biometricOnly: true,
  );

  test('El acceso exige autenticación local y registro remoto', () async {
    expect(await login(), isTrue);
    expect(device.calls, 1);
    expect(accounts.calls, 1);
    expect(controller.isAuthenticated, isTrue);
    controller.logout();
    expect(controller.isAuthenticated, isFalse);
  });

  test('No envía credenciales si se cancela la biometría', () async {
    device.result = const AuthResult(AuthStatus.cancelled, 'Cancelado');
    expect(await login(), isFalse);
    expect(accounts.calls, 0);
    expect(controller.isAuthenticated, isFalse);
  });

  test('El error de la base de datos mantiene la pantalla bloqueada', () async {
    accounts.failure = const AccountException('Servidor no disponible');
    expect(await login(), isFalse);
    expect(controller.isAuthenticated, isFalse);
    expect(controller.error, 'Servidor no disponible');
  });

  test('Sin configuración no solicita biometría ni acceso remoto', () async {
    accounts.isConfigured = false;
    expect(await login(), isFalse);
    expect(device.calls, 0);
    expect(accounts.calls, 0);
  });

  test('Cerrar sesión invalida una solicitud pendiente y evita intentos dobles', () async {
    accounts.pending = Completer<void>();
    final attempt = login();
    await Future<void>.delayed(Duration.zero);
    expect(accounts.calls, 1);
    expect(await login(), isFalse);
    controller.logout();
    accounts.pending!.complete();
    expect(await attempt, isFalse);
    expect(controller.isAuthenticated, isFalse);
  });
  test('Detecta huellas aunque falle la consulta de soporte', () async {
    device.supportError = true;
    await controller.init();
    expect(controller.hasBiometrics, isTrue);
    expect(controller.isSupported, isTrue);
  });

  test('Espera el regreso de Android al primer plano tras biometría', () async {
    var foreground = true;
    final mobile = AuthController(device, accounts, isForeground: () => foreground);
    addTearDown(mobile.dispose);
    device.onAuthenticate = () {
      foreground = false;
      Timer(const Duration(milliseconds: 100), () => foreground = true);
    };
    await mobile.init();
    final result = await mobile.login(email: 'student@example.com',
      password: 'test-only', biometricOnly: true);
    expect(result, isTrue);
    expect(accounts.calls, 1);
  });

  test('Cerrar sesión mientras regresa el diálogo impide el acceso remoto', () async {
    var foreground = true;
    final mobile = AuthController(device, accounts, isForeground: () => foreground);
    addTearDown(mobile.dispose);
    device.onAuthenticate = () => foreground = false;
    await mobile.init();
    final attempt = mobile.login(email: 'student@example.com',
      password: 'test-only', biometricOnly: true);
    await Future<void>.delayed(Duration.zero);
    mobile.logout();
    foreground = true;
    expect(await attempt, isFalse);
    expect(accounts.calls, 0);
  });
  test('Detección negativa no sustituye la autenticación nativa', () async {
    device.supportError = true;
    device.enrolled = false;
    await controller.init();
    expect(controller.hasBiometrics, isFalse);
    device.result = const AuthResult(AuthStatus.notEnrolled, 'Sin huella registrada');
    expect(await login(), isFalse);
    expect(device.calls, 1);
    expect(accounts.calls, 0);
    expect(controller.isAuthenticated, isFalse);
    device.result = const AuthResult(AuthStatus.success);
    expect(await login(), isTrue);
    expect(accounts.calls, 1);
  });
}
