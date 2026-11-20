import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/biometric_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _login(BuildContext context, {required bool biometricOnly}) async {
    final auth = context.read<AuthController>();
    final ok = await auth.login(biometricOnly: biometricOnly);
    if (!context.mounted) return;
    if (ok) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(auth.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Icon(Icons.shield_outlined, size: 80, color: Colors.indigo),
                const SizedBox(height: 16),
                Text(AppStrings.appName, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text('Accede de forma segura'),
                const SizedBox(height: 48),
                if (auth.isLoading)
                  const CircularProgressIndicator()
                else ...[
                  BiometricButton(
                    enabled: auth.hasBiometrics,
                    onPressed: () => _login(context, biometricOnly: true),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.pin_outlined),
                    label: const Text('Usar PIN, patrón o código'),
                    onPressed: auth.isSupported
                        ? () => _login(context, biometricOnly: false)
                        : null,
                  ),
                ],
                if (!auth.isSupported || !auth.hasBiometrics)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      auth.isSupported ? AppStrings.notEnrolled : AppStrings.notSupported,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}