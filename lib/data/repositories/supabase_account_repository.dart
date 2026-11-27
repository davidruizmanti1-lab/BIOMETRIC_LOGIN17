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
        uri.host.endsWith('.supabase.co') &&
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
      return http.Response.fromStream(response);
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

    await closeBrisaSession();
    final client = _clientFactory();
    String? token;
    try {
      final response = await _post(
        client,
        '/auth/v1/token?grant_type=password',
        body: {'email': email, 'password': password},
      );
      if (response.statusCode == 400 || response.statusCode == 401) {
        throw const AccountException('Credenciales incorrectas o cuenta no habilitada.');
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

      final result = await _post(
        client,
        '/rest/v1/rpc/secureapp_register_access',
        token: token,
      );
      if (result.statusCode < 200 || result.statusCode >= 300) {
        throw const AccountException('No se pudo registrar el acceso.');
      }
      // Sin IA, se mantiene el cierre de sesión del proyecto original.
      if (enableBrisa) { _brisaToken = token; token = null; }
    } on TimeoutException {
      throw const AccountException('La conexión tardó demasiado. Intenta nuevamente.');
    } on http.ClientException {
      throw const AccountException('Revisa tu conexión a internet.');
    } on FormatException {
      throw const AccountException('Respuesta inválida del servidor.');
    } finally {
      if (token != null) {
        try {
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
    if (!enableBrisa || token == null || !BrisaFaq.safe(question)) return null;
    final client = _clientFactory();
    try {
      final response = await _post(client, '/functions/v1/brisa', token: token, body: {'question': question});
      if (response.statusCode != 200 || _brisaToken != token) return null;
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) return null;
      final raw = body['topic'];
      final topics = BrisaFaq.validTopics(raw is String ? raw : null);
      return topics.isEmpty ? null : topics.join(',');
    } catch (_) { return null; } finally { client.close(); }
  }

  @override
  Future<void> closeBrisaSession() async {
    final token = _brisaToken;
    _brisaToken = null;
    if (token == null) return;
    final client = _clientFactory();
    try { await _post(client, '/auth/v1/logout?scope=local', token: token); }
    catch (_) {} finally { client.close(); }
  }
}
