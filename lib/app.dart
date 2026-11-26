import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/controllers/auth_controller.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/splash_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthController>().init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final auth = context.read<AuthController>();
    if (state == AppLifecycleState.detached ||
        (state == AppLifecycleState.paused && !auth.checkingBiometrics)) {
      auth.logout();
    } else if (state == AppLifecycleState.resumed && !auth.isAuthenticated) {
      auth.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return MaterialApp(
      title: 'SecureApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF254C79), useMaterial3: true),
      home: auth.initializing
          ? const SplashScreen()
          : auth.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}
