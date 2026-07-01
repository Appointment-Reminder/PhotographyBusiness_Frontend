import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/presentation/widgets/check_circle.dart';
import 'package:photography_business_frontend/core/presentation/widgets/current_badge.dart';
import 'package:photography_business_frontend/core/presentation/widgets/empty_circle.dart';

class PriceHistoryRow extends StatelessWidget {
  final String from;
  final String? to;       // null = present
  final String amount;
  final String currency;
  final bool isCurrent;

  const PriceHistoryRow({
    super.key,
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primaryText.withOpacity(0.05)
            : Colors.transparent,
        border: const Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Indicator
          isCurrent ? const CheckCircle() : const EmptyCircle(),
          const SizedBox(width: 10),

          // Date range + badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$from → ${to ?? 'present'}',
                      style: AppTextStyles.mono12.copyWith(
                        color: isCurrent
                            ? AppColors.primaryText
                            : AppColors.mutedText,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      const CurrentBadge(),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Row(
            children: [
              Text(
                amount,
                style: AppTextStyles.mono12.copyWith(
                  color: isCurrent
                      ? AppColors.primaryText
                      : AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                currency,
                style: AppTextStyles.monoMuted12,
              ),
            ],
          ),
        ],
      ),
    );
  }
}