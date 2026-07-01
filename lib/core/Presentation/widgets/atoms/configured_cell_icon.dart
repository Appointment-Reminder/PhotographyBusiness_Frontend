import 'package:flutter/material.dart';

class ConfiguredCellIcon extends StatelessWidget {
  const ConfiguredCellIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E), // green-500
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 12,
        color: Colors.white,
      ),
    );
  }
}