import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/velero_theme.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _step = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _next() {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_email.text.trim())) {
      setState(() => _error = 'Escribe un correo válido.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() { _step = true; _error = null; });
  }

  Future<void> _login(bool biometricOnly) async {
    if (_password.text.isEmpty) {
      setState(() => _error = 'Escribe tu contraseña.');
      return;
    }
    final auth = context.read<AuthController>();
    final password = _password.text;
    _password.clear();
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    await auth.login(email: _email.text.trim(), password: password, biometricOnly: biometricOnly);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final keyboard = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: LayoutBuilder(builder: (context, box) {
        final showHero = box.maxHeight > 540 && !keyboard;
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (showHero) Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/images/velero/galeria-balcon.webp', fit: BoxFit.cover),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Color(0x22073B50), Color(0xE6073B50)],
              ))),
              const Positioned(left: 20, bottom: 20, right: 20, child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.sailing, color: VeleroTheme.lightAqua, size: 36),
                  Text('Velero2H', style: TextStyle(color: Colors.white, fontSize: 36, fontFamily: 'serif')),
                  Text('Tu escape al Caribe', style: TextStyle(color: Colors.white)),
                ],
              )),
            ]),
          )),
          if (showHero) const SizedBox(height: 20),
          Text(_step ? 'Verifica tu acceso' : 'Bienvenido a bordo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_step) ...[
            Text(_email.text.trim(), maxLines: 1, overflow: TextOverflow.ellipsis),
            TextField(controller: _password, enabled: !auth.isLoading, obscureText: true,
              autocorrect: false, enableSuggestions: false, textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(labelText: 'Contraseña', prefixIcon: Icon(Icons.lock_outline))),
          ] else TextField(controller: _email, keyboardType: TextInputType.emailAddress,
            autocorrect: false, textInputAction: TextInputAction.next, onSubmitted: (_) => _next(),
            decoration: const InputDecoration(labelText: 'Correo electrónico', prefixIcon: Icon(Icons.email_outlined))),
          if (_error != null || (_step && auth.error != null))
            Text(_error ?? auth.error!, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          const SizedBox(height: 10),
          if (!_step) FilledButton(onPressed: _next, child: const Text('Continuar'))
          else if (keyboard) FilledButton(onPressed: () => FocusScope.of(context).unfocus(), child: const Text('Listo'))
          else ...[
            FilledButton.icon(onPressed: auth.isLoading || !auth.hasBiometrics || !auth.isConfigured ? null : () => _login(true),
              icon: const Icon(Icons.fingerprint), label: const Text('Ingresar con biometría')),
            TextButton(onPressed: auth.isLoading || !auth.isSupported || !auth.isConfigured ? null : () => _login(false),
              child: const Text('Usar seguridad del dispositivo')),
            TextButton(onPressed: auth.isLoading ? null : () => setState(() { _step = false; _password.clear(); _error = null; }), child: const Text('Cambiar correo')),
          ],
          if (auth.isLoading) const LinearProgressIndicator(),
          if (_step && !keyboard && !auth.isConfigured) const Text('Configura Supabase antes de ingresar.'),
          if (_step && !keyboard && auth.isConfigured && !auth.hasBiometrics) const Text('Registra una huella o usa la seguridad del dispositivo.', style: TextStyle(fontSize: 12)),
          if (box.maxHeight > 420 && !keyboard) const Padding(padding: EdgeInsets.only(top: 10), child: Text('Acceso privado · verificación local y Supabase', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: VeleroTheme.teal))),
        ]);
      }),
    )));
  }
}
