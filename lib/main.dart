import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/repositories/biometric_auth_repository.dart';
import 'data/repositories/supabase_account_repository.dart';
import 'presentation/controllers/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController(
        BiometricAuthRepository(),
        SupabaseAccountRepository(
          url: const String.fromEnvironment('SUPABASE_URL'),
          publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
          enableBrisa: const bool.fromEnvironment('VELERO2H_BRISA_AI'),
        ),
        isForeground: () => WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
      ),
      child: const App(),
    ),
  );
}
