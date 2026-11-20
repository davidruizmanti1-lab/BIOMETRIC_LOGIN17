
import '../entities/auth_result.dart';

abstract class AuthRepository {
  /// Comprueba si el dispositivo admite autenticación.
  Future<bool> isDeviceSupported();

  /// Comprueba si existen datos biométricos registrados.
  Future<bool> hasEnrolledBiometrics();

  /// Solicita autenticación al sistema operativo.
  ///
  /// biometricOnly = true:
  /// Exige huella o reconocimiento facial.
  ///
  /// biometricOnly = false:
  /// Permite credenciales del dispositivo cuando
  /// el sistema operativo las admite.
  Future<AuthResult> authenticate({
    required bool biometricOnly,
  });
}
