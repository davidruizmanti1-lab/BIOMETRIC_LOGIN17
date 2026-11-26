abstract class AccountRepository {
  bool get isConfigured;

  Future<void> registerAccess({required String email, required String password});
}

class AccountException implements Exception {
  final String message;

  const AccountException(this.message);
}
