import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';
import '../../domain/workflow/appointment_event.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';
import '../../domain/workflow/workflow_board.dart';
import '../../domain/workflow/workflow_column.dart';
import '../../domain/workflow/workflow_viewer.dart';
import '../providers/appointment_providers.dart';
import '../widgets/workflow/cancel_refund_drop_zones.dart';
import '../widgets/workflow/workflow_column_view.dart';

/// Kanban "Workflow" page: a Business's open Appointments by Appointment
/// Status. Read-only for now.
class WorkflowPage extends ConsumerStatefulWidget {
  final int businessId;
  const WorkflowPage({super.key, required this.businessId});

  @override
  ConsumerState<WorkflowPage> createState() => _WorkflowPageState();
}

class _WorkflowPageState extends ConsumerState<WorkflowPage> {
  bool _showClosed = false;
  WorkflowDragData? _dragging;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(packagesPricingMapProvider.notifier)
          .loadForBusiness(widget.businessId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentListNotifierProvider(widget.businessId));
    final members =
        ref.watch(businessMembersProvider(widget.businessId)).members;
    final pricingState = ref.watch(packagesPricingMapProvider);

    final packagesById = {
      for (final list in pricingState.packagesByCategory.values)
        for (final p in list) p.id: p,
    };
    final membersById = {for (final m in members) m.id: m};

    final viewer = _resolveViewer(members);

    final board = WorkflowBoard.build(
      viewer: viewer,
      appointments: state.appointments,
      packagesById: packagesById,
      membersById: membersById,
      showClosed: _showClosed,
    );

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOGRAPHY STUDIO',
              style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Workflow', style: AppTextStyles.heading24),
              const Spacer(),
              Text('Show closed', style: AppTextStyles.muted12),
              const SizedBox(width: 8),
              Switch(
                value: _showClosed,
                onChanged: (v) => setState(() => _showClosed = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatsStrip(board: board),
          const SizedBox(height: 16),
          CancelRefundDropZones(
            dragging: _dragging,
            isEligible: _canCloseOut,
            onDrop: _onCloseOutDrop,
          ),
          Expanded(child: _buildBoard(state.isLoading, state.error, board, viewer)),
        ],
      ),
    );
  }

  /// Assign flow for a Needs Assignment Appointment: member picker, then
  /// PATCH `member_id`, then `assign`. Reusable entry point (also for the
  /// Needs Assignment -> Scheduled drag).
  Future<void> startAssignFlow(int appointmentId) async {
    final memberId = await _pickMember();
    if (memberId == null || !mounted) return;
    final error = await ref
        .read(appointmentListNotifierProvider(widget.businessId).notifier)
        .assignAndSchedule(
          businessId: widget.businessId,
          appointmentId: appointmentId,
          memberId: memberId,
        );
    if (error != null) _showSnack(error);
  }

  /// "Assign to…" on an already-assigned card: PATCH `member_id` only.
  Future<void> _reassign(int appointmentId) async {
    final memberId = await _pickMember();
    if (memberId == null || !mounted) return;
    final error = await ref
        .read(appointmentListNotifierProvider(widget.businessId).notifier)
        .reassign(
          businessId: widget.businessId,
          appointmentId: appointmentId,
          memberId: memberId,
        );
    if (error != null) _showSnack(error);
  }

  /// Returns the chosen BusinessMember.id, or null when dismissed.
  Future<int?> _pickMember() {
    final members = ref
        .read(businessMembersProvider(widget.businessId))
        .members
        .where((m) => m.isActive)
        .toList();
    return showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Assign to'),
        children: [
          if (members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No active team members in this business'),
            ),
          for (final m in members)
            SimpleDialogOption(
              onPressed: () => Navigator.of(ctx).pop(m.id),
              child: Text(m.userName ?? m.userEmail ?? 'Unknown'),
            ),
        ],
      ),
    );
  }

  Future<void> _advance(WorkflowCard card, AppointmentEvent event) async {
    final error = await ref
        .read(appointmentListNotifierProvider(widget.businessId).notifier)
        .fireEvent(
          businessId: widget.businessId,
          appointmentId: card.appointmentId,
          event: event,
        );
    if (error != null && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  /// A card was dropped on [to]. Invalid moves show a snackbar and send no
  /// request; Needs Assignment -> Scheduled goes to [_onAssignDrop].
  Future<void> _onDrop(WorkflowDragData data, WorkflowColumn to) async {
    final event = eventForMove(data.from, to);
    if (event == null) {
      _showSnack('Cannot move from ${data.from.label} to ${to.label}');
      return;
    }
    if (event == AppointmentEvent.assign) {
      _onAssignDrop(data.card);
      return;
    }
    await _advance(data.card, event);
  }

  bool _canCloseOut(WorkflowDragData data) {
    final appointments = ref
        .read(appointmentListNotifierProvider(widget.businessId))
        .appointments;
    final match = appointments.where((a) => a.id == data.card.appointmentId);
    return match.isNotEmpty && canCancelOrRefund(match.first.status);
  }

  /// A card was dropped on the Cancel or Refund zone: confirm, then fire.
  Future<void> _onCloseOutDrop(
      WorkflowDragData data, AppointmentEvent event) async {
    setState(() => _dragging = null);
    final verb = event == AppointmentEvent.canceled ? 'Cancel' : 'Refund';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$verb appointment?'),
        content: Text('$verb the appointment for ${data.card.clientName}? '
            'It will leave the board.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Keep')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text(verb)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _advance(data.card, event);
  }

  /// Needs Assignment -> Scheduled drop: the same flow as "Assign…".
  void _onAssignDrop(WorkflowCard card) => startAssignFlow(card.appointmentId);

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// The current user's role on this Business. The business owner always
  /// counts as owner; otherwise the user's BusinessMember decides, and an
  /// unresolved member gets the restricted view.
  WorkflowViewer _resolveViewer(List<BusinessMember> members) {
    final auth = ref.watch(authNotifierProvider);
    final userId = auth is AuthAuthenticated ? auth.user.id : null;
    if (userId == null) return WorkflowViewer.fromMember(null);
    if (ref.watch(selectedBusinessProvider)?.ownerId == userId) {
      return WorkflowViewer.manager;
    }
    final mine = members.where((m) => m.userId == userId);
    return WorkflowViewer.fromMember(mine.isEmpty ? null : mine.first);
  }

  Widget _buildBoard(
      bool isLoading, String? error, WorkflowBoard board, WorkflowViewer viewer) {
    if (isLoading && board.totalCount == 0) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error, style: AppTextStyles.muted12));
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < board.columns.length; i++) ...[
          if (i > 0) const SizedBox(width: 16),
          Expanded(
            child: WorkflowColumnView(
              column: board.columns[i],
              cards: board.cardsIn(board.columns[i]),
              onAdvance: _advance,
              onAssign: viewer.canAssign
                  ? (card) => startAssignFlow(card.appointmentId)
                  : null,
              onReassign: viewer.canAssign
                  ? (card) => _reassign(card.appointmentId)
                  : null,
              onDrop: _onDrop,
              onDragChanged: (d) => setState(() => _dragging = d),
            ),
          ),
        ],
      ],
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final WorkflowBoard board;
  const _StatsStrip({required this.board});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (final col in board.columns) ...[
            Text(col.label, style: AppTextStyles.muted12),
            const SizedBox(width: 8),
            Text('${board.countIn(col)}', style: AppTextStyles.monoMuted11),
            const SizedBox(width: 24),
          ],
          const Spacer(),
          Text('${board.totalCount} active', style: AppTextStyles.monoMuted11),
        ],
      ),
    );
  }
}
