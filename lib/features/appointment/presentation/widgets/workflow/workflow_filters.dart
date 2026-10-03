import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import '../photographer_colors.dart';

String _firstName(BusinessMember m) {
  final name = (m.userName?.trim().isNotEmpty ?? false)
      ? m.userName!.trim()
      : (m.userEmail?.trim() ?? 'Unknown');
  return name.split(RegExp(r'\s+')).first;
}

/// Photographer filter chips ("FILTER  All  Anna  Ben"). Tapping the selected
/// chip clears the filter. Owner/admin only (see
/// `WorkflowViewer.showsFiltersAndLegend`).
class WorkflowFilterChips extends StatelessWidget {
  final List<BusinessMember> members;
  final int? selectedMemberId;
  final ValueChanged<int?> onChanged;

  const WorkflowFilterChips({
    super.key,
    required this.members,
    required this.selectedMemberId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('FILTER',
            style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.5)),
        _Chip(
          label: 'All',
          selected: selectedMemberId == null,
          onTap: () => onChanged(null),
        ),
        for (final m in members)
          _Chip(
            label: _firstName(m),
            dot: PhotographerColors.of(m.id),
            selected: selectedMemberId == m.id,
            onTap: () => onChanged(selectedMemberId == m.id ? null : m.id),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? dot;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.dot,
  });

  @override
  Widget build(BuildContext context) {
    final accent = dot ?? AppColors.border;
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.active : AppColors.sidebarBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? accent : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dot != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.muted12.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Footer legend: a colour dot and full name per photographer.
class WorkflowLegend extends StatelessWidget {
  final List<BusinessMember> members;

  const WorkflowLegend({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 20,
              runSpacing: 6,
              children: [
                for (final m in members)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: PhotographerColors.of(m.id),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(m.userName ?? m.userEmail ?? 'Unknown',
                          style: AppTextStyles.monoMuted10),
                    ],
                  ),
              ],
            ),
          ),
          Text('DRAG TO MOVE',
              style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.5)),
        ],
      ),
    );
  }
}
