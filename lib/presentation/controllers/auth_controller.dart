
import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthController(this._repository);

  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isSupported = false;
  bool _hasBiometrics = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isSupported => _isSupported;
  bool get hasBiometrics => _hasBiometrics;
  String? get error => _error;

  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _isSupported = await _repository.isDeviceSupported();
      _hasBiometrics =
          await _repository.hasEnrolledBiometrics();
    } catch (_) {
      _isSupported = false;
      _hasBiometrics = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required bool biometricOnly,
  }) async {
    if (_isLoading) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final AuthResult result =
          await _repository.authenticate(
        biometricOnly: biometricOnly,
      );

      _isAuthenticated = result.isSuccess;
      _error = result.isSuccess ? null : result.message;

      return result.isSuccess;
    } catch (_) {
      _isAuthenticated = false;
      _error = 'Error inesperado al iniciar sesión';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }
}
