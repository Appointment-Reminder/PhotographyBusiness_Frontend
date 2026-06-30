import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/commission/member_commission_card.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/member/member_list_card.dart';


class TeamCommissionsView extends StatefulWidget {
  const TeamCommissionsView({super.key});

  @override
  State<TeamCommissionsView> createState() => _TeamCommissionsViewState();
}

class _TeamCommissionsViewState extends State<TeamCommissionsView> {
  final List<MemberData> _members = [
    MemberData(id: 'm1', name: 'Sophie Martin',  role: 'Senior Photographer', email: 'sophie@studio.com'),
    MemberData(id: 'm2', name: 'Lucas Fontaine',  role: 'Photographer',        email: 'lucas@studio.com'),
    MemberData(id: 'm3', name: 'Amélie Dubois',   role: 'Junior Photographer', email: 'amelie@studio.com'),
    MemberData(id: 'm4', name: 'Marc Leblanc',    role: 'Sales Manager',       email: 'marc@studio.com'),
  ];

  // commissions per member id
  final Map<String, List<CommissionData>> _commissions = {
    'm1': [
      CommissionData(packageId: 'tourist-a', packageName: 'Package A', categoryName: 'Tourist', categoryId: 1,  value: '10',  isPercent: true),
      CommissionData(packageId: 'wedding-a', packageName: 'Package A', categoryName: 'Wedding', categoryId: 2, value: '150', isPercent: false),
      CommissionData(packageId: 'business-a',packageName: 'Package A', categoryName: 'Business', categoryId: 3, value: '8',   isPercent: true),
    ],
    'm2': [
      CommissionData(packageId: 'tourist-a', packageName: 'Package A', categoryName: 'Tourist', categoryId: 1,  value: '8',   isPercent: true),
      CommissionData(packageId: 'wedding-c', packageName: 'Package C', categoryName: 'Wedding', categoryId: 2, value: '12',  isPercent: true),
    ],
    'm3': [
      CommissionData(packageId: 'tourist-a', packageName: 'Package A', categoryName: 'Tourist', categoryId: 1, value: '5',   isPercent: true),
    ],
    'm4': [
      CommissionData(packageId: 'wedding-b', packageName: 'Package B', categoryName: 'Wedding', categoryId: 1, value: '120', isPercent: false),
      CommissionData(packageId: 'business-c',packageName: 'Package C', categoryName: 'Business', categoryId: 2, value: '6',   isPercent: true),
    ],
  };

  String _selectedId = 'm1';
  String? _editingId;

  MemberData get _selectedMember =>
      _members.firstWhere((m) => m.id == _selectedId);

  List<CommissionData> get _selectedCommissions =>
      _commissions[_selectedId] ?? [];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          Text('PHOTOGRAPHY STUDIO', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('Team & Commissions', style: AppTextStyles.heading24),
          const SizedBox(height: 32),

          // Cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MemberListCard(
                members:      _members,
                selectedId:   _selectedId,
                editingId:    _editingId,
                onSelect:     (id) => setState(() { _selectedId = id; _editingId = null; }),
                onEditTap:    (id) => setState(() { _selectedId = id; _editingId = id; }),
                onCancelEdit: ()   => setState(() => _editingId = null),
                onSave: (id, name, role, email) {
                  setState(() {
                    final m = _members.firstWhere((m) => m.id == id);
                    m.name  = name;
                    m.role  = role;
                    m.email = email;
                    _editingId = null;
                  });
                },
              ),
              const SizedBox(width: 20),
              Expanded(
                child: MemberCommissionsCard(
                  memberName:  _selectedMember.name,
                  memberRole:  _selectedMember.role,
                  memberEmail: _selectedMember.email,
                  commissions: _selectedCommissions,
                  onValueChanged: (packageId) {
                    // value already updated via controller
                  },
                  onTypeChanged: (packageId, isPercent) {
                    setState(() {
                      final c = _selectedCommissions
                          .firstWhere((c) => c.packageId == packageId);
                      c.isPercent = isPercent;
                    });
                  },
                  onRemove: (packageId) {
                    setState(() {
                      _commissions[_selectedId]
                          ?.removeWhere((c) => c.packageId == packageId);
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}