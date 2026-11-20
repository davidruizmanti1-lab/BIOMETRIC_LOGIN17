enum AuthStatus {
  success,
  failed,
  notSupported,
  notEnrolled,
  noCredentials,
  cancelled,
  error,
}

class AuthResult {
  final AuthStatus status;
  final String? message;

  const AuthResult(this.status, [this.message]);

  bool get isSuccess => status == AuthStatus.success;
}
