
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
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasEnrolledBiometrics() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      return types.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthResult> authenticate({
    required bool biometricOnly,
  }) async {
    try {
      final supported = await isDeviceSupported();

      if (!supported) {
        return const AuthResult(
          AuthStatus.notSupported,
          AppStrings.notSupported,
        );
      }

      if (biometricOnly) {
        final enrolled = await hasEnrolledBiometrics();

        if (!enrolled) {
          return const AuthResult(
            AuthStatus.notEnrolled,
            AppStrings.notEnrolled,
          );
        }
      }

      final authenticated = await _auth.authenticate(
        localizedReason: AppStrings.authReason,
        biometricOnly: biometricOnly,
        persistAcrossBackgrounding: true,
      );

      if (authenticated) {
        return const AuthResult(AuthStatus.success);
      }

      return const AuthResult(
        AuthStatus.failed,
        AppStrings.failed,
      );
    } on LocalAuthException catch (error) {
      return _mapError(error);
    } catch (_) {
      return const AuthResult(
        AuthStatus.error,
        AppStrings.genericError,
      );
    }
  }

  AuthResult _mapError(LocalAuthException error) {
    switch (error.code) {
      case LocalAuthExceptionCode.userCanceled:
      case LocalAuthExceptionCode.systemCanceled:
        return const AuthResult(
          AuthStatus.cancelled,
          AppStrings.cancelled,
        );

      case LocalAuthExceptionCode.noBiometricsEnrolled:
        return const AuthResult(
          AuthStatus.notEnrolled,
          AppStrings.notEnrolled,
        );

      case LocalAuthExceptionCode.noCredentialsSet:
        return const AuthResult(
          AuthStatus.noCredentials,
          AppStrings.noCredentials,
        );

      case LocalAuthExceptionCode.uiUnavailable:
        return const AuthResult(
          AuthStatus.error,
          AppStrings.uiUnavailable,
        );

      default:
        return const AuthResult(
          AuthStatus.error,
          AppStrings.genericError,
        );
    }
  }
}
