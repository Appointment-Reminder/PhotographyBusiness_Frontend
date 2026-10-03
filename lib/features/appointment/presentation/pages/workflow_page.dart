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
import '../../domain/workflow/workflow_viewer.dart';
import '../providers/appointment_providers.dart';
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
          Expanded(child: _buildBoard(state.isLoading, state.error, board)),
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

  Widget _buildBoard(bool isLoading, String? error, WorkflowBoard board) {
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
