import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class EmptyCircle extends StatelessWidget {
  const EmptyCircle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
      ),
    );
  }
}