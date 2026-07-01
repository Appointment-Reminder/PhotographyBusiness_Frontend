import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CheckCircle extends StatelessWidget {
  const CheckCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: const BoxDecoration(
        color: AppColors.primaryText,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check,
        size: 10,
        color: AppColors.active,
      ),
    );
  }
}