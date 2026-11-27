import 'package:local_auth/local_auth.dart';

import '../../core/constants/app_strings.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';

class BiometricAuthRepository implements AuthRepository {
  final LocalAuthentication _auth;

  BiometricAuthRepository([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  @override
  Future<bool> isDeviceSupported() async {
    try {
      if (await _auth.isDeviceSupported()) return true;
    } catch (_) {
      // Algunos fabricantes reportan las capacidades por separado.
    }
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasEnrolledBiometrics() async {
    try {
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthResult> authenticate({required bool biometricOnly}) async {
    try {
      // El diálogo nativo es la fuente de verdad: evita rechazar el acceso
      // por una consulta de capacidades desactualizada.
      if (biometricOnly && !await hasEnrolledBiometrics()) {
        return const AuthResult(AuthStatus.notEnrolled, AppStrings.notEnrolled);
      }
      final ok = await _auth.authenticate(
        localizedReason: AppStrings.authReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: false,
      );
      return ok ? const AuthResult(AuthStatus.success) : const AuthResult(AuthStatus.failed, AppStrings.failed);
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.userCanceled || LocalAuthExceptionCode.systemCanceled => const AuthResult(AuthStatus.cancelled, AppStrings.cancelled),
        LocalAuthExceptionCode.noBiometricsEnrolled => const AuthResult(AuthStatus.notEnrolled, AppStrings.notEnrolled),
        LocalAuthExceptionCode.noCredentialsSet => const AuthResult(AuthStatus.noCredentials, AppStrings.noCredentials),
        LocalAuthExceptionCode.temporaryLockout => const AuthResult(AuthStatus.failed, 'Demasiados intentos. Espera antes de volver a intentar.'),
        LocalAuthExceptionCode.biometricLockout => const AuthResult(AuthStatus.failed, 'Desbloquea la biometría desde los ajustes del dispositivo.'),
        LocalAuthExceptionCode.uiUnavailable => const AuthResult(AuthStatus.error, AppStrings.uiUnavailable),
        _ => const AuthResult(AuthStatus.error, AppStrings.genericError),
      };
    } catch (_) {
      return const AuthResult(AuthStatus.error, AppStrings.genericError);
    }
  }
}
