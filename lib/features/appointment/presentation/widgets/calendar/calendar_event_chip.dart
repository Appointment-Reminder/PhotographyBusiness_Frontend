import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import '../../../domain/entities/appointment.dart';
import '../photographer_colors.dart';

class CalendarEventChip extends StatefulWidget {
  final Appointment appointment;
  final bool isSelected;
  final VoidCallback onTap;

  const CalendarEventChip(
      {super.key, required this.appointment, required this.isSelected, required this.onTap});

  @override
  State<CalendarEventChip> createState() => _CalendarEventChipState();
}

class _CalendarEventChipState extends State<CalendarEventChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.appointment;
    final color = PhotographerColors.of(a.memberId);
    final dark = HSLColor.fromColor(color).withLightness(0.3).toColor();
    final fmt = DateFormat('HH:mm');
    final start = fmt.format(a.appointmentDate);
    final time = a.appointmentDuration == null
        ? start
        : '$start–${fmt.format(a.appointmentDate.add(Duration(minutes: a.appointmentDuration!)))}';
    final highlighted = widget.isSelected || _hovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(highlighted ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected ? color : color.withOpacity(0.3),
              width: widget.isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(time, style: AppTextStyles.mono10.copyWith(color: dark, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(a.clientFirstName,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body14.copyWith(fontSize: 11, color: dark, fontWeight: FontWeight.w500)),
            if (a.appointmentLocation != null)
              Text('📍 ${a.appointmentLocation}',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.muted12.copyWith(fontSize: 10, color: dark.withOpacity(0.7))),
          ]),
        ),
      ),
    );
  }
}