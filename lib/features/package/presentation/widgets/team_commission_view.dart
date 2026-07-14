import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/commission_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/member/commission/member_commission_map_notifier.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/commission/member_commission_card.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/member/member_list_card.dart';

class TeamCommissionsView extends ConsumerStatefulWidget {
  final int businessId;
  const TeamCommissionsView({super.key, required this.businessId});

  @override
  ConsumerState<TeamCommissionsView> createState() => _TeamCommissionsViewState();
}

class _TeamCommissionsViewState extends ConsumerState<TeamCommissionsView> {
  String? _selectedId;

  static const _inviteRoles = ['photographer', 'assistant', 'admin'];

  @override
  void initState() {
    super.initState();
    // businessMembersProvider auto-loads itself on first watch/read below.
    Future.microtask(() =>
        ref.read(memberCommissionMapProvider.notifier).loadForBusiness(widget.businessId));
  }

  List<MemberData> _toMemberData(List<BusinessMember> members) {
    return members.map((m) => MemberData(
      id: m.id.toString(),
      name: m.userName ?? 'Unknown',
      role: m.role,
      email: m.userEmail ?? '',
    )).toList();
  }

  List<CommissionData> _commissionsFor(MemberCommissionMapState s, int memberId) {
    final byPkg = s.commissions[memberId] ?? {};
    return s.packages.map((pkg) {
      final c = byPkg[pkg.id];
      return CommissionData(
        packageId: pkg.id.toString(),
        packageName: pkg.name,
        categoryName: '',
        categoryId: pkg.categoryId,
        value: c?.commissionAmount.toString() ?? '0',
        isPercent: c?.commissionIsPercentage ?? false,
      );
    }).toList();
  }

  String _categoryName(MemberCommissionMapState s, int categoryId) {
    final match = s.categories.where((c) => c.id == categoryId).firstOrNull;
    return match?.name ?? 'Unknown';
  }

  Future<void> _handleInvite(String email, String role) =>
      ref.read(businessMemberFormNotifierProvider.notifier).invite(widget.businessId, email, role);

  @override
  Widget build(BuildContext context) {
    final memberState = ref.watch(businessMembersProvider(widget.businessId));
    final commissionState = ref.watch(memberCommissionMapProvider);

    final isLoading = (memberState.isLoading && memberState.members.isEmpty) ||
        (commissionState.isLoading && commissionState.packages.isEmpty);
    if (isLoading) return const Center(child: CircularProgressIndicator());

    final error = memberState.error ?? commissionState.error;
    if (error != null) return Center(child: Text(error));

    final members = _toMemberData(memberState.members);

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOGRAPHY STUDIO', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('Team & Commissions', style: AppTextStyles.heading24),
          const SizedBox(height: 32),
          Expanded(
            child: members.isEmpty ? _buildEmpty() : _buildContent(members, commissionState),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    // No members yet — still render the card so "+ Invite" bootstraps the team.
    return MemberListCard(
      members: const [],
      selectedId: '',
      editingId: null,
      onSelect: (_) {},
      onEditTap: (_) {},
      onCancelEdit: () {},
      onSave: (_, __, ___, ____) {},
      onInvite: _handleInvite,
      inviteRoles: _inviteRoles,
    );
  }

  Widget _buildContent(List<MemberData> members, MemberCommissionMapState s) {
    if (_selectedId == null || !members.any((m) => m.id == _selectedId)) {
      _selectedId = members.first.id;
    }
    final selected = members.firstWhere((m) => m.id == _selectedId);
    final commissions = _commissionsFor(s, int.parse(_selectedId!))
        .map((c) => c.copyWithCategoryName(_categoryName(s, c.categoryId)))
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MemberListCard(
          members: members,
          selectedId: _selectedId!,
          editingId: null,
          onSelect: (id) => setState(() => _selectedId = id),
          onEditTap: (id) {},
          onCancelEdit: () {},
          onSave: (id, name, role, email) {},
          onInvite: _handleInvite,
          inviteRoles: _inviteRoles,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: MemberCommissionsCard(
            memberName: selected.name,
            memberRole: selected.role,
            memberEmail: selected.email,
            commissions: commissions,
            onValueChanged: (packageId) {},
            onTypeChanged: (packageId, isPercent) {},
            onRemove: (packageId) {},
          ),
        ),
      ],
    );
  }
}