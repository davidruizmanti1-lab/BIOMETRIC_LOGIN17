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
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    _isAuthenticated = false;
    _closeRemote();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

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
    if (_disposed || _isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      _isSupported = await _detect(_repository.isDeviceSupported);
      _hasBiometrics = await _detect(_repository.hasEnrolledBiometrics);
      _isSupported = _isSupported || _hasBiometrics;
    } finally {
      _initializing = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _detect(Future<bool> Function() check) async {
    try {
      return await check().timeout(const Duration(seconds: 5));
    } catch (_) {
      return false;
    }
  }

  // Android puede devolver el resultado antes de restaurar el estado resumed.
  Future<bool> _waitForForeground(int revision) async {
    for (var attempt = 0; attempt < 40; attempt++) {
      if (_disposed || revision != _revision) return false;
      if (_isForeground()) return true;
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    return false;
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool biometricOnly,
  }) async {
    if (_disposed || _isLoading || _isAuthenticated) return false;
    if (!_isForeground()) return false;
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
      if (!await _waitForForeground(revision)) {
        if (revision == _revision) _error = 'Vuelve a abrir la aplicación e intenta de nuevo.';
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
