import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/velero_theme.dart';
import '../controllers/auth_controller.dart';
import '../widgets/velero_brand.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _login(bool biometricOnly) async {
    final auth = context.read<AuthController>();
    if (auth.isLoading || !(_form.currentState?.validate() ?? false)) return;
    final email = _email.text.trim();
    final password = _password.text;
    FocusScope.of(context).unfocus();
    _password.clear();
    await auth.login(email: email, password: password, biometricOnly: biometricOnly);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Center(child: VeleroBrand(size: 82)),
              const SizedBox(height: 10),
              const Text('Velero2H', textAlign: TextAlign.center,
                style: TextStyle(color: VeleroTheme.ocean, fontSize: 32,
                  fontFamily: 'serif', fontWeight: FontWeight.bold)),
              const Text('Tu escape al Caribe', textAlign: TextAlign.center,
                style: TextStyle(color: VeleroTheme.teal)),
              const SizedBox(height: 20),
              Text('Bienvenido a bordo', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              const Text('Ingresa tu cuenta y verifica tu identidad.'),
              const SizedBox(height: 18),
              TextFormField(
                key: const ValueKey('login-email'),
                controller: _email,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                enableSuggestions: false,
                enabled: !auth.checkingBiometrics,
                onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                decoration: const InputDecoration(labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined)),
                validator: (value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                    .hasMatch(value?.trim() ?? '') ? null : 'Escribe un correo válido.',
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('login-password'),
                controller: _password,
                focusNode: _passwordFocus,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                enabled: !auth.checkingBiometrics,
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock_outline)),
                validator: (value) => (value?.isEmpty ?? true) ? 'Escribe tu contraseña.' : null,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('login-biometric'),
                onPressed: auth.isLoading || !auth.isConfigured ? null : () => _login(true),
                icon: const Icon(Icons.fingerprint),
                label: const Text('Ingresar con huella o rostro'),
              ),
              TextButton(
                onPressed: auth.isLoading || !auth.isConfigured ? null : () => _login(false),
                child: const Text('Usar seguridad del dispositivo'),
              ),
              if (auth.error != null)
                Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              if (!auth.isConfigured)
                const Text('Falta la configuración de Supabase. Ejecuta la app con secureapp.config.json.'),
              if (auth.isLoading) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 8),
                Text(auth.checkingBiometrics ? 'Verificando identidad en Android…' : 'Comprobando conexión…'),
              ],
              if (!auth.hasBiometrics && !auth.isLoading)
                TextButton.icon(onPressed: auth.init, icon: const Icon(Icons.refresh),
                  label: const Text('Volver a detectar biometría')),
              const SizedBox(height: 12),
              const Text('Acceso privado · Velero2H', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: VeleroTheme.teal)),
            ]),
          ),
        ),
      ),
    );
  }
}
