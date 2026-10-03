import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import '../../../domain/workflow/workflow_board.dart';
import '../photographer_colors.dart';

class WorkflowCardView extends StatelessWidget {
  final WorkflowCard card;

  /// Advance button label and handler; no button when either is null.
  final String? advanceLabel;
  final VoidCallback? onAdvance;

  const WorkflowCardView({
    super.key,
    required this.card,
    this.advanceLabel,
    this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final color = PhotographerColors.of(card.memberId);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.clientName,
                      style: AppTextStyles.body14.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.appointmentListHeaderBG,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              card.packageLabel,
                              style: AppTextStyles.monoMuted10,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                        const Spacer(),
                        _Avatar(color: color, initials: card.photographerInitials),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('dd MMM').format(card.date),
                      style: AppTextStyles.monoMuted10,
                    ),
                    if (advanceLabel != null && onAdvance != null) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onAdvance,
                          child: Text(advanceLabel!),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final Color color;
  final String? initials;
  const _Avatar({required this.color, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        initials ?? '',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
