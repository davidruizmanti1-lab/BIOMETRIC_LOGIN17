import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:biometric_login/data/repositories/supabase_account_repository.dart';
import 'package:biometric_login/domain/repositories/account_repository.dart';

void main() {
  for (final scenario in [
    (400, 'invalid_credentials', 'Revisa el correo'),
    (401, 'invalid_api_key', 'clave publicable'),
    (403, 'forbidden', 'clave publicable'),
    (400, 'email_provider_disabled', 'no está habilitado'),
  ]) {
    test('Rechazo de acceso: ' + scenario.$2, () async {
      final paths = <String>[];
      final repo = SupabaseAccountRepository(
        url: 'https://example.supabase.co',
        publishableKey: 'sb_publishable_test_only',
        clientFactory: () => MockClient((request) async {
          paths.add(request.url.path);
          return http.Response(jsonEncode({'error_code': scenario.$2}), scenario.$1);
        }),
      );
      await expectLater(
        repo.registerAccess(email: 'test@example.com', password: 'test-only'),
        throwsA(isA<AccountException>().having((e) => e.message, 'mensaje', contains(scenario.$3))),
      );
      expect(paths, ['/auth/v1/token']);
      expect(repo.brisaAvailable, isFalse);
    });
  }
}
