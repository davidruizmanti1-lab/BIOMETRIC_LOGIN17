
import 'package:flutter_test/flutter_test.dart';
import 'package:biometric_login/domain/entities/auth_result.dart';

void main() {
  group('AuthResult', () {
    test('Reconoce una autenticación exitosa', () {
      const result = AuthResult(AuthStatus.success);

      expect(result.isSuccess, isTrue);
    });

    test('Reconoce una autenticación fallida', () {
      const result = AuthResult(AuthStatus.failed);

      expect(result.isSuccess, isFalse);
    });
  });
}
