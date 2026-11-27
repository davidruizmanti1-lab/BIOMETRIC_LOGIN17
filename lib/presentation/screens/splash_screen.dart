import 'package:flutter/material.dart';
import '../../core/velero_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: VeleroTheme.ocean,
    body: SafeArea(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.sailing_outlined, size: 82, color: VeleroTheme.gold),
      SizedBox(height: 18),
      Text('Velero2H', style: TextStyle(fontSize: 36, color: Colors.white, fontFamily: 'serif')),
      Text('SANTA MARTA · COLOMBIA', style: TextStyle(color: VeleroTheme.lightAqua, letterSpacing: 2, fontSize: 12)),
      SizedBox(height: 30),
      CircularProgressIndicator(color: VeleroTheme.aqua),
      SizedBox(height: 12),
      Text('Verificando tu acceso', style: TextStyle(color: Colors.white70)),
    ]))),
  );
}
