import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/commission_providers.dart';
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(memberCommissionMapProvider.notifier).loadForBusiness(widget.businessId));
  }

  List<MemberData> _toMemberData(MemberCommissionMapState s) {
    return s.members.map((m) => MemberData(
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
        categoryName: '', // you don't have category name here unless you also load categories
        categoryId: pkg.categoryId,
        value: c?.commissionPercent.toString() ?? '0',
        isPercent: true, // API only stores commission_percent, no EUR mode — see below
      );
    }).toList();
  }

  String _categoryName(MemberCommissionMapState s, int categoryId) {
    final match = s.categories.where((c) => c.id == categoryId).firstOrNull;
    return match?.name ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(memberCommissionMapProvider);
    if (s.isLoading && s.members.isEmpty) return const Center(child: CircularProgressIndicator());
    if (s.error != null) return Center(child: Text(s.error!));
    if (s.members.isEmpty) return const Center(child: Text('No team members yet'));

    final members = _toMemberData(s);
    _selectedId ??= members.first.id;
    final selected = members.firstWhere((m) => m.id == _selectedId);
    final commissions = _commissionsFor(s, int.parse(_selectedId!))
        .map((c) => c.copyWithCategoryName(_categoryName(s, c.categoryId)))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOGRAPHY STUDIO', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('Team & Commissions', style: AppTextStyles.heading24),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MemberListCard(
                members: members,
                selectedId: _selectedId!,
                editingId: null, // edit disabled until name/email endpoint exists — see comment above
                onSelect: (id) => setState(() => _selectedId = id),
                onEditTap: (id) {}, // TODO wire role-only edit via updateMemberRole
                onCancelEdit: () {},
                onSave: (id, name, role, email) {},
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MemberCommissionsCard(
                  memberName: selected.name,
                  memberRole: selected.role,
                  memberEmail: selected.email,
                  commissions: commissions,
                  onValueChanged: (packageId) {}, // committed on blur/save below, not per-keystroke
                  onTypeChanged: (packageId, isPercent) {}, // no-op: only % supported by API
                  onRemove: (packageId) {}, // no-op: no delete endpoint, see comment above
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}