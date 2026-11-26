import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login(bool biometricOnly) async {
    if (!_form.currentState!.validate()) return;
    final password = _password.text;
    _password.clear();
    FocusScope.of(context).unfocus();
    await context.read<AuthController>().login(
      email: _email.text,
      password: password,
      biometricOnly: biometricOnly,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.shield_outlined, size: 64, color: colors.primary),
                    const SizedBox(height: 16),
                    Text('SecureApp', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    const Text('Acceso privado a tu cuenta', textAlign: TextAlign.center),
                    const SizedBox(height: 36),
                    TextFormField(
                      controller: _email,
                      enabled: !auth.isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
                      validator: (value) => value == null || !value.trim().contains('@') ? 'Ingresa un correo válido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      enabled: !auth.isLoading,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Ingresa tu contraseña' : null,
                    ),
                    const SizedBox(height: 24),
                    if (auth.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      FilledButton.icon(
                        onPressed: auth.isConfigured && auth.hasBiometrics ? () => _login(true) : null,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Ingresar con biometría'),
                      ),
                      TextButton.icon(
                        onPressed: auth.isConfigured && auth.isSupported ? () => _login(false) : null,
                        icon: const Icon(Icons.lock_outline),
                        label: const Text('Usar seguridad del dispositivo'),
                      ),
                    ],
                    if (!auth.isConfigured)
                      const Text('Conexión a la base de datos pendiente.', textAlign: TextAlign.center)
                    else if (!auth.isSupported)
                      const Text('Este dispositivo no admite autenticación local.', textAlign: TextAlign.center)
                    else if (!auth.hasBiometrics)
                      const Text('Registra una huella o rostro en los ajustes del teléfono.', textAlign: TextAlign.center),
                    if (auth.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(auth.error!, textAlign: TextAlign.center, style: TextStyle(color: colors.error)),
                      ),
                    const SizedBox(height: 24),
                    Text('Desarrollo de Aplicaciones Móviles', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
