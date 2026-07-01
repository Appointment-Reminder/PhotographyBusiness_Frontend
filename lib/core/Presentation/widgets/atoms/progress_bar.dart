import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';

class ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final double width;

  const ProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.width = 128,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$current',
                style: AppTextStyles.mono12.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '/$total configured',
                style: AppTextStyles.monoMuted12,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: width,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.sidebarBg,
            borderRadius: BorderRadius.circular(99),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                color: AppColors.primaryText,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ],
    );
  }
}