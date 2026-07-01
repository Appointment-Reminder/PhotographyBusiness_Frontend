import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CurrentBadge extends StatelessWidget {
  const CurrentBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryText.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'current',
        style: AppTextStyles.mono10.copyWith(
          color: AppColors.primaryText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}