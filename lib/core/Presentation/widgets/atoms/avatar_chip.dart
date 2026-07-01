import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';


class AvatarChip extends StatelessWidget {
  final String initials;
  final double size;

  const AvatarChip({
    super.key,
    required this.initials,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryText.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTextStyles.mono11.copyWith(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}