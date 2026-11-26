import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SecureApp'),
        actions: [
          IconButton(
            onPressed: context.read<AuthController>().logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user_outlined, size: 88, color: Color(0xFF24734D)),
              SizedBox(height: 20),
              Text('Acceso autorizado', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Cuenta verificada y acceso registrado.', textAlign: TextAlign.center),
              SizedBox(height: 8),
              Text('Los datos de auditoría no se muestran en esta aplicación.', textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
