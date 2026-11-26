import 'dart:convert';

import 'package:biometric_login/data/repositories/supabase_account_repository.dart';
import 'package:biometric_login/domain/repositories/account_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const url = 'https://example.supabase.co';
  const key = 'sb_publishable_test_only';

  SupabaseAccountRepository repository(MockClient client) =>
      SupabaseAccountRepository(url: url, publishableKey: key, clientFactory: () => client);

  test('Autentica por HTTPS, registra mediante RPC y cierra la sesión', () async {
    final paths = <String>[];
    final client = MockClient((request) async {
      paths.add(request.url.path);
      expect(request.method, 'POST');
      expect(request.url.scheme, 'https');
      expect(request.headers['apikey'], key);
      if (request.url.path == '/auth/v1/token') {
        expect(request.url.queryParameters['grant_type'], 'password');
        expect(jsonDecode(request.body)['email'], 'student@example.com');
        return http.Response('{"access_token":"test-token"}', 200);
      }
      expect(request.headers['authorization'], 'Bearer test-token');
      expect(jsonDecode(request.body), isEmpty);
      return http.Response('', 204);
    });
    await repository(client).registerAccess(email: 'student@example.com', password: 'test-only');
    expect(paths, ['/auth/v1/token', '/rest/v1/rpc/secureapp_register_access', '/auth/v1/logout']);
  });

  test('Una cuenta inválida no puede registrar accesos', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/auth/v1/token');
      return http.Response('{}', 400);
    });
    await expectLater(
      repository(client).registerAccess(email: 'student@example.com', password: 'wrong'),
      throwsA(isA<AccountException>()),
    );
  });

  test('Un error de RPC impide completar el acceso', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/auth/v1/token') return http.Response('{"access_token":"test-token"}', 200);
      if (request.url.path == '/auth/v1/logout') return http.Response('', 204);
      return http.Response('{}', 403);
    });
    await expectLater(
      repository(client).registerAccess(email: 'student@example.com', password: 'test-only'),
      throwsA(isA<AccountException>()),
    );
  });

  test('Rechaza una URL no segura o una clave secreta', () {
    expect(SupabaseAccountRepository(url: 'http://example.supabase.co', publishableKey: key).isConfigured, isFalse);
    expect(SupabaseAccountRepository(url: url, publishableKey: 'sb_secret_fake').isConfigured, isFalse);
  });
}
