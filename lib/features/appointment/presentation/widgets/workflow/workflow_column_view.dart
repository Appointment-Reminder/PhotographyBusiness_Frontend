import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import '../../../domain/workflow/appointment_event.dart';
import '../../../domain/workflow/workflow_board.dart';
import '../../../domain/workflow/workflow_column.dart';
import 'workflow_card_view.dart';

class WorkflowColumnView extends StatelessWidget {
  final WorkflowColumn column;
  final List<WorkflowCard> cards;

  /// Called when a card's Advance button is pressed.
  final void Function(WorkflowCard card, AppointmentEvent event)? onAdvance;

  const WorkflowColumnView({
    super.key,
    required this.column,
    required this.cards,
    this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        column.label,
                        style: AppTextStyles.body14.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.active,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text('${cards.length}',
                          style: AppTextStyles.monoMuted10),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  column.description,
                  style: AppTextStyles.monoMuted10,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: cards.isEmpty
                ? const _EmptyPlaceholder()
                : ListView.separated(
                    itemCount: cards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final card = cards[i];
                      final event = advanceEventFor(column);
                      return WorkflowCardView(
                        card: card,
                        advanceLabel: advanceLabelFor(column),
                        onAdvance: event == null || onAdvance == null
                            ? null
                            : () => onAdvance!(card, event),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('empty', style: AppTextStyles.monoMuted10),
      ),
    );
  }
}
