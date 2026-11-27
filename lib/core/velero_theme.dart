import 'package:flutter/material.dart';

// Identidad costera de Velero2H.
abstract final class VeleroTheme {
  static const aqua = Color(0xFF25BFC7);
  static const lightAqua = Color(0xFF78E0DE);
  static const teal = Color(0xFF08717B);
  static const ocean = Color(0xFF073B50);
  static const water = Color(0xFFD9F7F5);
  static const ivory = Color(0xFFF4FBFA);
  static const gold = Color(0xFFD6B474);
  static const ink = Color(0xFF193B45);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ivory,
    colorScheme: ColorScheme.fromSeed(seedColor: aqua).copyWith(
      primary: teal, onPrimary: Colors.white, secondary: ocean,
      surface: ivory, onSurface: ink, primaryContainer: water,
      onPrimaryContainer: ocean,
    ),
    appBarTheme: const AppBarThemeData(backgroundColor: ivory, foregroundColor: ocean, elevation: 0),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Colors.white, indicatorColor: lightAqua),
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    )),
    inputDecorationTheme: const InputDecorationThemeData(
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18))),
    ),
  );
}
