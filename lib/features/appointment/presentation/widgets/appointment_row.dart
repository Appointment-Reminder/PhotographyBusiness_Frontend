import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import '../../domain/entities/appointment.dart';
import 'photographer_colors.dart';

class AppointmentRow extends StatelessWidget {
  final Appointment appointment;
  final Package? package; // resolved by caller via appointment.packageId
  final BusinessMember? photographer; // resolved by caller via appointment.memberId
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AppointmentRow({
    super.key,
    required this.appointment,
    required this.package,
    required this.photographer,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = PhotographerColors.of(appointment.memberId);
    final photographerName = photographer?.userName ?? 'Unassigned';

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            color: isExpanded ? AppColors.sidebarBg.withOpacity(0.5) : null,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('EEE, d MMM').format(appointment.appointmentDate),
                          style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                      Text(DateFormat('HH:mm').format(appointment.appointmentDate),
                          style: AppTextStyles.monoMuted11),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appointment.clientName,
                          style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
                      Text(package?.name ?? 'No package',
                          style: AppTextStyles.muted12, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: Row(
                    children: [
                      Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(photographerName,
                            style: AppTextStyles.body14, overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: _StatusChip(status: appointment.status),
                ),
                Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.mutedText),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            color: AppColors.sidebarBg.withOpacity(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    if (appointment.clientEmail != null)
                      _InfoItem(icon: Icons.email_outlined, text: appointment.clientEmail!),
                    if (appointment.clientPhone != null)
                      _InfoItem(icon: Icons.phone, text: appointment.clientPhone!),
                    if (appointment.appointmentLocation != null)
                      _InfoItem(icon: Icons.place_outlined, text: appointment.appointmentLocation!),
                    if (appointment.appointmentDuration != null)
                      _InfoItem(icon: Icons.timer_outlined, text: appointment.appointmentDuration!),
                    if (appointment.numberOfPersons != null)
                      _InfoItem(
                          icon: Icons.people_outline, text: '${appointment.numberOfPersons} people'),
                    if (appointment.priceAtBooking != null)
                      _InfoItem(
                        icon: Icons.euro,
                        text:
                            '${appointment.priceAtBooking!.toStringAsFixed(0)} '
                            '(deposit ${appointment.depositAmount?.toStringAsFixed(0) ?? '—'})',
                      ),
                  ],
                ),
                if (appointment.appointmentNote != null) ...[
                  const SizedBox(height: 8),
                  Text(appointment.appointmentNote!, style: AppTextStyles.muted12),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Spacer(),
                    TextButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 14),
                      label: const Text('Edit'),
                    ),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.mutedText),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.muted12),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        status,
        textAlign: TextAlign.center,
        style: AppTextStyles.mono10.copyWith(color: AppColors.mutedText),
      ),
    );
  }
}
