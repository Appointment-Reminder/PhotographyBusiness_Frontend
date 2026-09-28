import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import '../photographer_colors.dart';

class CalendarFiltersBar extends StatelessWidget {
  final DateTime month;
  final List<BusinessMember> members;
  final int? photographerFilter;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int?> onPhotographerChanged;

  const CalendarFiltersBar({
    super.key,
    required this.month,
    required this.members,
    required this.photographerFilter,
    required this.onPrev,
    required this.onNext,
    required this.onPhotographerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _NavButton(icon: Icons.chevron_left, onTap: onPrev),
      SizedBox(
        width: 160,
        child: Text(DateFormat('MMMM yyyy').format(month),
            textAlign: TextAlign.center,
            style: AppTextStyles.body16.copyWith(fontWeight: FontWeight.w600)),
      ),
      _NavButton(icon: Icons.chevron_right, onTap: onNext),
      const Spacer(),
      Wrap(spacing: 8, children: [
        for (final m in members)
          _PhotographerChip(
            name: (m.userName ?? 'Unknown').split(' ').first,
            color: PhotographerColors.of(m.id),
            isActive: photographerFilter == null || photographerFilter == m.id,
            onTap: () => onPhotographerChanged(photographerFilter == m.id ? null : m.id),
          ),
      ]),
    ]);
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 15, color: AppColors.mutedText),
    ),
  );
}

class _PhotographerChip extends StatelessWidget {
  final String name;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  const _PhotographerChip(
      {required this.name, required this.color, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isActive ? 1 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.1) : AppColors.active,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: isActive ? color.withOpacity(0.3) : AppColors.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(name, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    ),
  );
}