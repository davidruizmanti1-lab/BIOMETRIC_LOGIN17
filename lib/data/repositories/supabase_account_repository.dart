import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/brisa_session_repository.dart';
import '../../domain/services/brisa_faq.dart';

class SupabaseAccountRepository implements AccountRepository, BrisaSessionRepository {
  final String url;
  final String publishableKey;
  final bool enableBrisa;
  String? _brisaToken;
  int _sessionRevision = 0;
  http.Client? _brisaClient;
  final http.Client Function() _clientFactory;

  SupabaseAccountRepository({
    required this.url,
    required this.publishableKey,
    this.enableBrisa = false,
    http.Client Function()? clientFactory,
  }) : _clientFactory = clientFactory ?? http.Client.new;

  @override
  bool get isConfigured {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.scheme == 'https' &&
        RegExp(r'^[a-z0-9-]+\.supabase\.co$').hasMatch(uri.host) &&
        uri.userInfo.isEmpty &&
        (uri.path.isEmpty || uri.path == '/') &&
        (!uri.hasPort || uri.port == 443) &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        publishableKey.startsWith('sb_publishable_');
  }

  Uri _endpoint(String path) => Uri.parse(url).resolve(path);

  Future<http.Response> _post(
    http.Client client,
    String path, {
    Map<String, String>? body,
    String? token,
  }) async {
    final request = http.Request('POST', _endpoint(path))
      ..followRedirects = false
      ..headers.addAll({
        'apikey': publishableKey,
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      })
      ..body = jsonEncode(body ?? <String, String>{});

    return await (() async {
      final response = await client.send(request);
      // Evita acumular respuestas excesivas en la memoria.
      const maxBytes = 64 * 1024;
      final bytes = <int>[];
      await for (final chunk in response.stream) {
        if (bytes.length + chunk.length > maxBytes) {
          throw const FormatException('Respuesta demasiado grande');
        }
        bytes.addAll(chunk);
      }
      return http.Response.bytes(bytes, response.statusCode, headers: response.headers);
    })().timeout(const Duration(seconds: 15));
  }

  @override
  Future<void> registerAccess({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) {
      throw const AccountException('Configura la conexión a Supabase.');
    }

    final revision = _sessionRevision + 1;
    await closeBrisaSession();
    if (revision != _sessionRevision) {
      throw const AccountException('La sesión fue cancelada.');
    }
    final client = _clientFactory();
    String? token;
    try {
      final response = await _post(
        client,
        '/auth/v1/token?grant_type=password',
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
        // No mostrar cuerpos del servidor, claves, tokens ni credenciales.
        String? code;
        try {
          final error = jsonDecode(response.body);
          if (error is Map<String, dynamic>) {
            final value = error['error_code'] ?? error['code'];
            if (value is String) code = value;
          }
        } on FormatException {
          // Una respuesta no JSON tampoco permite confirmar credenciales.
        }
        if (code == 'invalid_credentials' || code == 'email_not_confirmed' ||
            code == 'user_banned') {
          throw const AccountException('No se pudo validar la cuenta. Revisa el correo y la contraseña.');
        }
        if (code == 'email_provider_disabled') {
          throw const AccountException('El acceso por correo no está habilitado en el servidor.');
        }
        if (response.statusCode == 401 || response.statusCode == 403) {
          throw const AccountException('Autenticación rechazada. Verifica la URL y la clave publicable de Supabase.');
        }
        throw const AccountException('Supabase rechazó la solicitud de acceso. Revisa la configuración y las credenciales.');
      }
      if (response.statusCode == 429) {
        throw const AccountException('Demasiados intentos. Intenta más tarde.');
      }
      if (response.statusCode != 200) {
        throw const AccountException('No se pudo conectar con autenticación.');
      }

      final data = jsonDecode(response.body);
      final accessToken = data is Map<String, dynamic> ? data['access_token'] : null;
      if (accessToken is! String || accessToken.isEmpty) {
        throw const AccountException('No se recibió una sesión válida.');
      }
      token = accessToken;
      if (revision != _sessionRevision) {
        throw const AccountException('La sesión fue cancelada.');
      }

      final result = await _post(
        client,
        '/rest/v1/rpc/secureapp_register_access',
        token: token,
      );
      if (result.statusCode < 200 || result.statusCode >= 300) {
        throw const AccountException('No se pudo registrar el acceso.');
      }
      // Sin IA, se mantiene el cierre de sesión del proyecto original.
      if (revision != _sessionRevision) {
        throw const AccountException('La sesión fue cancelada.');
      }
      if (enableBrisa) {
        _brisaToken = token;
        token = null;
      }
    } on TimeoutException {
      throw const AccountException('La conexión tardó demasiado. Intenta nuevamente.');
    } on http.ClientException {
      throw const AccountException('Revisa tu conexión a internet.');
    } on FormatException {
      throw const AccountException('Respuesta inválida del servidor.');
    } finally {
      if (token != null) {
        try {
          if (enableBrisa) {
            try {
              await _post(client, '/rest/v1/rpc/velero2h_brisa_revoke', token: token);
            } catch (_) {}
          }
          await _post(client, '/auth/v1/logout?scope=local', token: token);
        } catch (_) {}
      }
      client.close();
    }
  }

  @override
  bool get brisaAvailable => enableBrisa && _brisaToken != null;

  @override
  Future<String?> askBrisa(String question) async {
    final token = _brisaToken;
    if (!enableBrisa || token == null || !BrisaFaq.safe(question) || _brisaClient != null) return null;
    final revision = _sessionRevision;
    final client = _clientFactory();
    _brisaClient = client;
    try {
      final response = await _post(client, '/functions/v1/brisa', token: token, body: {'question': question});
      if (response.statusCode != 200 || _brisaToken != token || revision != _sessionRevision) return null;
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return null;
      final raw = body['topic'];
      final topics = BrisaFaq.validTopics(raw is String ? raw : null);
      return topics.isEmpty ? null : topics.join(',');
    } catch (_) {
      return null;
    } finally {
      if (identical(_brisaClient, client)) {
        _brisaClient = null;
        client.close();
      }
    }
  }

  @override
  Future<void> closeBrisaSession() async {
    _sessionRevision++;
    final token = _brisaToken;
    _brisaToken = null;
    _brisaClient?.close();
    _brisaClient = null;
    if (token == null) return;
    final client = _clientFactory();
    try {
      // Revocación específica de BRISA; el logout se intenta incluso si falla.
      try {
        await _post(client, '/rest/v1/rpc/velero2h_brisa_revoke', token: token);
      } catch (_) {}
      await _post(client, '/auth/v1/logout?scope=local', token: token);
    } catch (_) {
      // La sesión local ya fue eliminada.
    } finally {
      client.close();
    }
  }
}
