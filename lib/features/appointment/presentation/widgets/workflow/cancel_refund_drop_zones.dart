import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import '../../../domain/workflow/appointment_event.dart';
import 'workflow_column_view.dart';

/// "Cancel" and "Refund" drop zones, shown only while a card is being dragged
/// ([dragging] non-null). A zone accepts the card only when [isEligible] says
/// so; otherwise it renders disabled.
class CancelRefundDropZones extends StatelessWidget {
  final WorkflowDragData? dragging;
  final bool Function(WorkflowDragData data) isEligible;
  final void Function(WorkflowDragData data, AppointmentEvent event) onDrop;

  const CancelRefundDropZones({
    super.key,
    required this.dragging,
    required this.isEligible,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    final data = dragging;
    if (data == null) return const SizedBox.shrink();
    final eligible = isEligible(data);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: _Zone(
              label: 'Cancel',
              eligible: eligible,
              onDrop: (d) => onDrop(d, AppointmentEvent.canceled),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _Zone(
              label: 'Refund',
              eligible: eligible,
              onDrop: (d) => onDrop(d, AppointmentEvent.refund),
            ),
          ),
        ],
      ),
    );
  }
}

class _Zone extends StatelessWidget {
  final String label;
  final bool eligible;
  final void Function(WorkflowDragData data) onDrop;

  const _Zone(
      {required this.label, required this.eligible, required this.onDrop});

  @override
  Widget build(BuildContext context) {
    return DragTarget<WorkflowDragData>(
      onWillAcceptWithDetails: (_) => eligible,
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (context, candidates, _) {
        final hot = candidates.isNotEmpty;
        return Opacity(
          opacity: eligible ? 1 : 0.4,
          child: Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hot ? AppColors.active : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hot ? Colors.redAccent : AppColors.border,
                width: hot ? 2 : 1,
              ),
            ),
            child: Text(
              eligible ? label : '$label unavailable',
              style: AppTextStyles.muted12,
            ),
          ),
        );
      },
    );
  }
}
