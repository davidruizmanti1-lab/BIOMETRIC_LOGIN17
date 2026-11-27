import 'dart:async';

import 'package:biometric_login/data/repositories/supabase_account_repository.dart';
import 'package:biometric_login/domain/repositories/account_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const url = 'https://example.supabase.co';
  const key = 'sb_publishable_test_only';

  test('Rechaza hosts no autorizados y puertos alternativos', () {
    for (final bad in [
      'https://example.supabase.co.evil.test',
      'https://nested.example.supabase.co',
      'https://example.supabase.co:444',
    ]) {
      expect(SupabaseAccountRepository(url: bad, publishableKey: key).isConfigured, isFalse);
    }
  });

  test('El proyecto incorrecto no recibe credenciales', () async {
    var requests = 0;
    final repo = SupabaseAccountRepository(
      url: url, publishableKey: key,
      expectedHost: 'xsbrwkxptxqnfdzvygwl.supabase.co',
      clientFactory: () => MockClient((_) async {
        requests++;
        return http.Response('', 401);
      }),
    );
    expect(repo.isConfigured, isFalse);
    await expectLater(repo.registerAccess(email: 'test@example.com', password: 'test-only'),
      throwsA(isA<AccountException>()));
    expect(requests, 0);
    expect(SupabaseAccountRepository(
      url: 'https://xsbrwkxptxqnfdzvygwl.supabase.co',
      publishableKey: key,
      expectedHost: 'xsbrwkxptxqnfdzvygwl.supabase.co',
    ).isConfigured, isTrue);
  });

  test('Rechaza una respuesta de acceso excesiva', () async {
    final repo = SupabaseAccountRepository(
      url: url, publishableKey: key,
      clientFactory: () => MockClient((_) async => http.Response(List.filled(65537, 'x').join(), 200)),
    );
    await expectLater(repo.registerAccess(email: 'test@example.com', password: 'test-only'),
      throwsA(isA<AccountException>()));
  });

  test('Cierre de sesión revoca BRISA y descarta respuesta tardía', () async {
    final pending = Completer<http.Response>();
    final paths = <String>[];
    final repo = SupabaseAccountRepository(
      url: url, publishableKey: key, enableBrisa: true,
      clientFactory: () => MockClient((request) async {
        paths.add(request.url.path);
        if (request.url.path == '/auth/v1/token') {
          return http.Response('{"access_token":"test-token"}', 200);
        }
        if (request.url.path == '/functions/v1/brisa') return pending.future;
        return http.Response('', 204);
      }),
    );
    await repo.registerAccess(email: 'test@example.com', password: 'test-only');
    final first = repo.askBrisa('precio');
    expect(await repo.askBrisa('reserva'), isNull);
    await repo.closeBrisaSession();
    pending.complete(http.Response('{"topic":"precios"}', 200));
    expect(await first, isNull);
    expect(repo.brisaAvailable, isFalse);
    expect(paths, contains('/rest/v1/rpc/velero2h_brisa_revoke'));
  });
  test('Un acceso cancelado no registra sesión ni reactiva BRISA', () async {
    final pending = Completer<http.Response>();
    final started = Completer<void>();
    final paths = <String>[];
    final repo = SupabaseAccountRepository(
      url: url, publishableKey: key, enableBrisa: true,
      clientFactory: () => MockClient((request) async {
        paths.add(request.url.path);
        if (request.url.path == '/auth/v1/token') {
          started.complete();
          return pending.future;
        }
        return http.Response('', 204);
      }),
    );
    final attempt = repo.registerAccess(email: 'test@example.com', password: 'test-only');
    final assertion = expectLater(attempt, throwsA(isA<AccountException>()));
    await started.future;
    await repo.closeBrisaSession();
    pending.complete(http.Response('{"access_token":"test-token"}', 200));
    await assertion;
    expect(repo.brisaAvailable, isFalse);
    expect(paths, isNot(contains('/rest/v1/rpc/secureapp_register_access')));
    expect(paths, contains('/auth/v1/logout'));
  });
}
