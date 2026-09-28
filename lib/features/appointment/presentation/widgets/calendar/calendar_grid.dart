import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import '../../../domain/entities/appointment.dart';
import 'calendar_event_chip.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime month;
  final Map<int, List<Appointment>> appointmentsByDay;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.appointmentsByDay,
    required this.selectedId,
    required this.onSelect,
  });

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final leading = DateTime(month.year, month.month, 1).weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final rows = ((leading + daysInMonth) / 7).ceil();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        Container(
          color: AppColors.sidebarBg,
          child: Row(children: [
            for (final d in _days)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(color: AppColors.border),
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(d.toUpperCase(),
                      style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.5)),
                ),
              ),
          ]),
        ),
        for (var r = 0; r < rows; r++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < 7; c++) _cell(r * 7 + c - leading + 1, daysInMonth),
              ],
            ),
          ),
      ]),
    );
  }

  Widget _cell(int day, int daysInMonth) {
    final valid = day >= 1 && day <= daysInMonth;
    final appts = valid ? (appointmentsByDay[day] ?? const <Appointment>[]) : const <Appointment>[];
    final isToday = valid && DateUtils.isSameDay(DateTime(month.year, month.month, day), DateTime.now());

    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 110),
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: valid ? null : AppColors.sidebarBg.withOpacity(0.5),
          border: const Border(
            right: BorderSide(color: AppColors.border),
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: valid
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isToday ? AppColors.primaryText : null,
                shape: BoxShape.circle,
              ),
              child: Text('$day',
                  style: AppTextStyles.mono11.copyWith(
                    color: isToday ? AppColors.active : AppColors.mutedText,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                  )),
            ),
          ),
          const SizedBox(height: 4),
          for (final a in appts)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: CalendarEventChip(
                appointment: a,
                isSelected: a.id == selectedId,
                onTap: () => onSelect(a.id),
              ),
            ),
        ])
            : null,
      ),
    );
  }
}