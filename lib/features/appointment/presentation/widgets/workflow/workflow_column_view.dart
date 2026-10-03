import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import '../../../domain/workflow/appointment_event.dart';
import '../../../domain/workflow/workflow_board.dart';
import '../../../domain/workflow/workflow_column.dart';
import 'workflow_card_view.dart';

/// Payload carried while a card is dragged: the card and the column it
/// started in.
typedef WorkflowDragData = ({WorkflowCard card, WorkflowColumn from});

class WorkflowColumnView extends StatelessWidget {
  final WorkflowColumn column;
  final List<WorkflowCard> cards;

  /// Called when a card's Advance button is pressed.
  final void Function(WorkflowCard card, AppointmentEvent event)? onAdvance;

  /// Called when a card dragged from another column is dropped here.
  final void Function(WorkflowDragData data, WorkflowColumn to)? onDrop;

  /// Called with the dragged card when a drag starts, and with null when it
  /// ends (dropped or canceled).
  final void Function(WorkflowDragData? dragging)? onDragChanged;

  const WorkflowColumnView({
    super.key,
    required this.column,
    required this.cards,
    this.onAdvance,
    this.onDrop,
    this.onDragChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<WorkflowDragData>(
      onWillAcceptWithDetails: (d) => d.data.from != column,
      onAcceptWithDetails: (d) => onDrop?.call(d.data, column),
      builder: (context, candidates, _) => _buildColumn(candidates.isNotEmpty),
    );
  }

  Widget _buildColumn(bool highlighted) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: highlighted ? Border.all(color: AppColors.border) : null,
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
                      final view = WorkflowCardView(
                        card: card,
                        advanceLabel: advanceLabelFor(column),
                        onAdvance: event == null || onAdvance == null
                            ? null
                            : () => onAdvance!(card, event),
                      );
                      return Draggable<WorkflowDragData>(
                        data: (card: card, from: column),
                        onDragStarted: () =>
                            onDragChanged?.call((card: card, from: column)),
                        onDragEnd: (_) => onDragChanged?.call(null),
                        feedback: SizedBox(
                          width: 240,
                          child: Material(
                            color: Colors.transparent,
                            child: view,
                          ),
                        ),
                        childWhenDragging: Opacity(opacity: 0.4, child: view),
                        child: view,
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
