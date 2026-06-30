import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class MatrixColumnHeader extends StatelessWidget {
  final String name;
  final Color color;

  const MatrixColumnHeader({
    super.key,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: AppTextStyles.body14.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}