import 'package:flutter/material.dart';
import '../../core/velero_theme.dart';

// El emblema original se incluye en el APK, sin conexión.
class VeleroBrand extends StatelessWidget {
  const VeleroBrand({super.key, this.size = 96});
  final double size;
  static const asset = 'assets/images/velero/logo-oficial.webp';

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Velero 2H, agencia de turismo',
    image: true,
    child: Container(
      width: size, height: size,
      padding: EdgeInsets.all(size * .035),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(size * .22),
        border: Border.all(color: VeleroTheme.gold.withValues(alpha: .55)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * .17),
        child: Image.asset(asset, fit: BoxFit.contain,
          excludeFromSemantics: true,
          errorBuilder: (_, error, stack) => Icon(Icons.sailing_outlined, size: size * .55, color: VeleroTheme.teal)),
      ),
    ),
  );
}
