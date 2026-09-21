import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/progress_bar.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/matrix_member_row..dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/webhook_matrix_card..dart';
import '../providers/jotform_providers.dart';
import '../providers/state/jotform_matrix_state.dart';
import '../widgets/assign_form_dialog.dart';

class JotformMatrixView extends ConsumerStatefulWidget {
  final int businessId;
  const JotformMatrixView({super.key, required this.businessId});

  @override
  ConsumerState<JotformMatrixView> createState() => _JotformMatrixViewState();
}

class _JotformMatrixViewState extends ConsumerState<JotformMatrixView> {
  final Set<String> _collapsed = {};

  static const _palette = [
    Color(0xFFF59E0B), Color(0xFF8B5CF6), Color(0xFF3B82F6), Color(0xFF10B981),
    Color(0xFFF43F5E), Color(0xFF06B6D4), Color(0xFFEF4444), Color(0xFF84CC16),
    Color(0xFFF97316), Color(0xFF6366F1),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(jotformMatrixNotifierProvider.notifier).loadForBusiness(widget.businessId));
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    if (p.length >= 2 && p[0].isNotEmpty && p[1].isNotEmpty) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  List<MatrixMemberData> _members(List<BusinessMember> ms) => ms
      .map((m) => MatrixMemberData(
            id: m.id.toString(),
            name: m.userName ?? 'Unknown',
            email: m.userEmail ?? '',
            initials: _initials(m.userName ?? 'U'),
          ))
      .toList();

  List<MatrixCategoryData> _categories(JotformMatrixState s) => s.categories
      .map((c) => MatrixCategoryData(
          id: c.id.toString(), name: c.name, color: _palette[c.id % _palette.length]))
      .toList();

  Future<void> _onCellTap(
    String memberId,
    String categoryId,
    List<MatrixMemberData> members,
    List<MatrixCategoryData> cats,
  ) async {
    final s = ref.read(jotformMatrixNotifierProvider);
    final mId = int.parse(memberId), cId = int.parse(categoryId);

    final formId = await showDialog<int>(
      context: context,
      builder: (_) => AssignFormDialog(
        memberName: members.firstWhere((m) => m.id == memberId).name,
        categoryName: cats.firstWhere((c) => c.id == categoryId).name,
        forms: s.forms,
        currentFormId: s.assignmentFor(mId, cId)?.formId,
      ),
    );
    if (formId == null) return;

    final ok = await ref
        .read(jotformMatrixNotifierProvider.notifier)
        .assign(formId: formId, memberId: mId, categoryId: cId);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(jotformMatrixNotifierProvider).error ?? 'Assignment failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(businessMembersProvider(widget.businessId));
    final s = ref.watch(jotformMatrixNotifierProvider);

    if ((memberState.isLoading && memberState.members.isEmpty) ||
        (s.isLoading && s.categories.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    final error = memberState.error ?? s.error;
    if (error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(error, style: AppTextStyles.muted14),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            ref.read(businessMembersProvider(widget.businessId).notifier).load(widget.businessId);
            ref.read(jotformMatrixNotifierProvider.notifier).loadForBusiness(widget.businessId);
          },
          child: const Text('Retry'),
        ),
      ]));
    }

    if (s.forms.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('No Jotform forms yet', style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Connect a Jotform account first.', style: AppTextStyles.muted12),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => ref.read(businessTabProvider.notifier).state = 'Jotform Integration',
          child: const Text('Set up Jotform integration'),
        ),
      ]));
    }

    if (memberState.members.isEmpty || s.categories.isEmpty) {
      return const Center(child: Text('No team members or categories yet'));
    }

    final members = _members(memberState.members);
    final cats = _categories(s);
    final configuredMap = s.configuredMap;
    final total = members.length * cats.length;
    final configured = configuredMap.values.fold<int>(0, (a, b) => a + b.length);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.grid_view, size: 18, color: AppColors.primaryText),
          const SizedBox(width: 10),
          Text('Jotform Assignments', style: AppTextStyles.heading16),
          const Spacer(),
          ProgressBar(current: configured, total: total),
        ]),
        const SizedBox(height: 4),
        Text('Click a cell to assign a Jotform to that member and category.',
            style: AppTextStyles.muted12),
        const SizedBox(height: 16),
        WebhookMatrixCard(
          members: members,
          categories: cats,
          configuredMap: configuredMap,
          collapsedMemberIds: _collapsed,
          onCellTap: (m, c) => _onCellTap(m, c, members, cats),
          onToggleCollapse: (id) =>
              setState(() => _collapsed.contains(id) ? _collapsed.remove(id) : _collapsed.add(id)),
        ),
      ]),
    );
  }
}
