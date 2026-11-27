import 'dart:async';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/brisa_session_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;
  final AccountRepository _accounts;
  final bool Function() _isForeground;

  AuthController(this._repository, this._accounts, {bool Function()? isForeground})
    : _isForeground = isForeground ?? (() => true);

  bool _initializing = true;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isSupported = false;
  bool _hasBiometrics = false;
  bool _checkingBiometrics = false;
  int _revision = 0;
  String? _error;

  bool get initializing => _initializing;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isSupported => _isSupported;
  bool get hasBiometrics => _hasBiometrics;
  bool get checkingBiometrics => _checkingBiometrics;
  bool get isConfigured => _accounts.isConfigured;
  String? get error => _error;
  BrisaSessionRepository? get _brisa => _accounts is BrisaSessionRepository ? _accounts as BrisaSessionRepository : null;
  bool get brisaAvailable => _isAuthenticated && (_brisa?.brisaAvailable ?? false);

  Future<String?> askBrisa(String q) async {
    if (!brisaAvailable || !_isForeground()) return null;
    final revision = _revision;
    final result = await _brisa?.askBrisa(q);
    return revision == _revision && _isAuthenticated && _isForeground() ? result : null;
  }

  void _closeRemote() {
    final brisa = _brisa;
    if (brisa != null) unawaited(brisa.closeBrisaSession().catchError((Object _) {}));
  }

  Future<void> init() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _isSupported = await _repository.isDeviceSupported().timeout(const Duration(seconds: 5));
      _hasBiometrics = await _repository.hasEnrolledBiometrics().timeout(const Duration(seconds: 5));
    } catch (_) {
      _isSupported = false;
      _hasBiometrics = false;
    } finally {
      _initializing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool biometricOnly,
  }) async {
    if (_isLoading || _isAuthenticated) return false;
    if (!isConfigured || email.trim().isEmpty || password.isEmpty) {
      _error = !isConfigured ? 'Configura Supabase antes de ingresar.' : 'Completa tus credenciales.';
      notifyListeners();
      return false;
    }

    final revision = ++_revision;
    _isLoading = true;
    _error = null;
    _checkingBiometrics = true;
    notifyListeners();

    try {
      final result = await _repository.authenticate(biometricOnly: biometricOnly);
      _checkingBiometrics = false;
      if (revision != _revision) return false;
      if (!result.isSuccess) {
        _error = result.message ?? 'No se pudo verificar el dispositivo.';
        return false;
      }
      await _accounts.registerAccess(email: email.trim(), password: password);
      if (revision != _revision || !_isForeground()) return false;
      _isAuthenticated = true;
      return true;
    } on AccountException catch (error) {
      if (revision == _revision) _error = error.message;
      return false;
    } catch (_) {
      if (revision == _revision) _error = 'No se pudo completar el acceso.';
      return false;
    } finally {
      if (!_isAuthenticated) _closeRemote();
      _checkingBiometrics = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _revision++;
    _closeRemote();
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }
}
