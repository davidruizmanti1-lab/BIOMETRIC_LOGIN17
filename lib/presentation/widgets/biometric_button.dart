
import 'package:flutter/material.dart';

class BiometricButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const BiometricButton({
    super.key,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: enabled ? onPressed : null,
      icon: const Icon(Icons.fingerprint),
      iconSize: 56,
      padding: const EdgeInsets.all(24),
      tooltip: 'Acceder con biometría',
    );
  }
}
