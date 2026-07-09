import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/column_header.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/member/molecule/member_edit_form.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/member/molecule/member_row.dart';


class MemberData {
  final String id;
  String name;
  String role;
  String email;

  MemberData({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });
}

class MemberListCard extends StatelessWidget {
  final List<MemberData> members;
  final String selectedId;
  final String? editingId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onEditTap;
  final void Function(String id, String name, String role, String email) onSave;
  final VoidCallback onCancelEdit;
  final double maxHeight;

  const MemberListCard({
    super.key,
    required this.members,
    required this.selectedId,
    required this.editingId,
    required this.onSelect,
    required this.onEditTap,
    required this.onSave,
    required this.onCancelEdit,
    this.maxHeight = 480,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: BoxConstraints(maxHeight: maxHeight,),
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ColumnHeader('Members'),
          Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                  itemCount: members.length,
                  itemBuilder: (context, i) {
                  final m = members[i];
                  if (editingId == m.id) {
                    return MemberEditForm(
                      initialName: m.name,
                      initialRole: m.role,
                      initialEmail: m.email,
                      onSave: (name, role, email) => onSave(m.id, name, role, email),
                      onCancel: onCancelEdit,
                    );
                  }
                  return MemberRow(
                    name: m.name,
                    role: m.role,
                    email: m.email,
                    isSelected: m.id == selectedId,
                    onTap: () => onSelect(m.id),
                    onEditTap: () => onEditTap(m.id),
                  );
                }
              )
          ),
        ],
      ),
    );
  }
}