import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/section_label.dart';
import 'package:photography_business_frontend/core/utils/money_format.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import '../../../domain/entities/appointment.dart';
import '../photographer_colors.dart';

class AppointmentDetailPanel extends StatelessWidget {
  final Appointment? appointment;
  final Package? package;
  final BusinessMember? photographer;
  final VoidCallback onClose;

  /// Add-on names by id; empty when the user cannot read the catalogue.
  final Map<int, String> addonNames;

  const AppointmentDetailPanel({
    super.key,
    required this.appointment,
    required this.package,
    required this.photographer,
    required this.onClose,
    this.addonNames = const {},
  });

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    if (a == null) return _empty();

    final color = PhotographerColors.of(a.memberId);
    final start = a.appointmentDate;
    final dur = a.appointmentDuration;
    final time = dur == null
        ? DateFormat('HH:mm').format(start)
        : '${DateFormat('HH:mm').format(start)} → ${DateFormat('HH:mm').format(start.add(Duration(minutes: dur)))} · ${dur ~/ 60}h${dur % 60 == 0 ? '' : '${dur % 60}m'}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          color: color.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            const Expanded(child: SectionLabel('Appointment')),
            GestureDetector(
              onTap: onClose,
              child: const Icon(Icons.close, size: 13, color: AppColors.mutedText),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Section('Date & Time', [
              Text(DateFormat('EEEE, d MMMM').format(start),
                  style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
              Text(time, style: AppTextStyles.monoMuted11),
            ]),
            if (a.appointmentLocation != null)
              _Section('Location', [Text('📍 ${a.appointmentLocation}', style: AppTextStyles.body14)]),
            _Section('Client', [
              Text(a.clientName, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
              if (a.clientEmail != null) Text(a.clientEmail!, style: AppTextStyles.muted12),
              if (a.clientPhone != null) Text(a.clientPhone!, style: AppTextStyles.monoMuted11),
            ]),
            _Section('Package', [
              Text(package?.name ?? 'No package', style: AppTextStyles.body14),
              if (a.numberOfPersons != null)
                Text('${a.numberOfPersons} person${a.numberOfPersons! > 1 ? 's' : ''}',
                    style: AppTextStyles.muted12),
              if (a.priceAtBooking != null)
                Text(
                    '${a.priceAtBooking!.toStringAsFixed(0)} EUR (deposit ${a.depositAmount?.toStringAsFixed(0) ?? '—'})',
                    style: AppTextStyles.monoMuted11),
            ]),
            if (a.addons.isNotEmpty)
              _Section('Add-ons', [
                for (final line in a.addons)
                  Row(children: [
                    Expanded(
                        child: Text('${line.label(addonNames)} x${line.quantity}',
                            style: AppTextStyles.body14)),
                    Text('${formatAmount(line.priceTotal)} EUR', style: AppTextStyles.monoMuted11),
                  ]),
              ]),
            _Section('Photographer', [
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(photographer?.userName ?? 'Unassigned',
                    style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
              ]),
            ]),
            if (a.appointmentNote != null && a.appointmentNote!.isNotEmpty)
              _Section('Notes', [
                Text(a.appointmentNote!,
                    style: AppTextStyles.body14.copyWith(fontSize: 12, fontStyle: FontStyle.italic)),
              ], last: true),
          ]),
        ),
      ]),
    );
  }

  Widget _empty() => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text('Click an appointment\nto see details',
          textAlign: TextAlign.center, style: AppTextStyles.monoMuted11),
    ),
  );
}

class _Section extends StatelessWidget {
  final String label;
  final List<Widget> children;
  final bool last;
  const _Section(this.label, this.children, {this.last = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SectionLabel(label),
      const SizedBox(height: 4),
      ...children,
    ]),
  );
}