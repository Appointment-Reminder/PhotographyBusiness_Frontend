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

  /// The Add-ons part of the expanded row; null shows none.
  final Widget? addonsSection;

  const AppointmentRow({
    super.key,
    required this.appointment,
    required this.package,
    required this.photographer,
    required this.isExpanded,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.addonsSection,
  });

  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '${remainingMinutes}m';
    }

    if (remainingMinutes == 0) {
      return '${hours}h';
    }

    return '${hours}h${remainingMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final color = PhotographerColors.of(appointment.memberId);
    final photographerName = photographer?.userName ?? 'Unassigned';

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
              color: isExpanded ? AppColors.sidebarBg.withOpacity(0.5) : null,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('EEE, d MMM').format(appointment.appointmentDate),
                          style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w500)),
                      Text(
                        appointment.appointmentDuration != null
                            ? '${DateFormat('HH:mm').format(appointment.appointmentDate)} ->'
                            '${DateFormat('HH:mm').format(appointment.appointmentDate.add(Duration(minutes: appointment.appointmentDuration!.toInt())))}'
                            : DateFormat('HH:mm').format(appointment.appointmentDate),
                        style: AppTextStyles.monoMuted11,
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                                appointment.clientName,
                                style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4,),
                          const Icon(
                            Icons.favorite_border,
                            size: 13,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2,),
                          Text(
                            '${appointment.numberOfPersons!}',
                            style: AppTextStyles.muted12,
                          ),
                          if (appointment.addons.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            _AddonsChip(count: appointment.addons.length),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 13,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 2,),
                          Text(appointment.appointmentLocation ?? 'No Location',
                              style: AppTextStyles.muted12, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 160,
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package?.name ?? "No Package",
                          style: AppTextStyles.muted12,
                          overflow: TextOverflow.ellipsis,),
                        Row(
                          children: [
                            Text(
                                package?.categoryId.toString() ?? "No category",
                              style: AppTextStyles.muted12,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 2,),
                            Text(
                              '·',
                              style: AppTextStyles.muted12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              formatDuration(appointment.appointmentDuration ?? 0),
                              style: AppTextStyles.muted12,
                            ),
                          ],
                        )
                      ],
                    )
                ),
                SizedBox(
                  width: 160,
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
                SizedBox(
                  width: 40,
                  child: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.mutedText),
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
                bottom: BorderSide(color: AppColors.border),
              ),
              color: AppColors.extentedAppointmentColor,
            ),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12,),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "CLIENT",
                          style: AppTextStyles.muted12,
                        ),
                        const SizedBox(height: 12,),
                        Text(
                          '${appointment.clientFirstName} ${appointment.clientLastName}',
                          style: AppTextStyles.mono,
                        ),
                        const SizedBox(height: 3,),
                        if (appointment.clientEmail != null)
                          _InfoItem(icon: Icons.email_outlined, text: appointment.clientEmail!),
                          const SizedBox(height: 3,),
                        if (appointment.clientPhone != null)
                          _InfoItem(icon: Icons.phone, text: appointment.clientPhone!),
                          const SizedBox(height: 3,),
                      ],
                    ), // CLIENT
                    const SizedBox(width: 80,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LOCATION & TIME",
                          style: AppTextStyles.muted12,
                        ),
                        const SizedBox(height: 12,),
                        Text(
                          '${appointment.appointmentLocation}',
                          style: AppTextStyles.mono,
                        ),
                        const SizedBox(height: 5,),
                        Text(
                          appointment.appointmentDuration != null
                              ? '${DateFormat('HH:mm').format(appointment.appointmentDate)} -'
                              '${DateFormat('HH:mm').format(appointment.appointmentDate.add(Duration(minutes: appointment.appointmentDuration!.toInt())))} (${formatDuration(appointment.appointmentDuration ?? 0)})'
                              : DateFormat('HH:mm').format(appointment.appointmentDate),
                          style: AppTextStyles.monoMuted11,
                        )
                      ],
                    ), // LOCATION AND TIME
                    const SizedBox(width: 80,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SESSION",
                          style: AppTextStyles.muted12,
                        ),
                        const SizedBox(height: 12,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 13,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 5,),
                            Text(
                                'CATEGORY',
                              style: AppTextStyles.mono,
                            ),
                            const SizedBox(width: 2,),
                            Text(
                              '·',
                              style: AppTextStyles.mono,
                            ),
                            const SizedBox(width: 2),
                            Text(
                                '${appointment.numberOfPersons} Persons',
                              style: AppTextStyles.mono,
                            )
                          ],
                        ), // COUPLE 2 Persons
                        const SizedBox(height: 5,),
                        RichText(
                          text:
                          TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Found via',
                                  style: AppTextStyles.monoMuted11,
                                ),
                                TextSpan(
                                  text: ' Instagram',
                                  style: AppTextStyles.mono,
                                )
                              ]
                          )
                        ),
                      ]
                    ), // SESSION
                    const SizedBox(width: 80,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NOTES",
                          style: AppTextStyles.muted12,
                        ),
                        const SizedBox(height: 12,),
                        if (appointment.appointmentNote != null) ...[
                          Text(appointment.appointmentNote!, style: AppTextStyles.mono),
                        ],
                      ],
                    ), //APPOINTMENT NOTES
                  ],
                ), //APPOINTMENT INFO
                if (addonsSection != null) addonsSection!,
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
                ), //BUTTONS EDIT DELETE
              ],
            ),
          ),
      ],
    );
  }
}

class _AddonsChip extends StatelessWidget {
  final int count;
  const _AddonsChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: AppColors.primaryText.withOpacity(0.08),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text('+$count add-on${count == 1 ? '' : 's'}', style: AppTextStyles.mono10),
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
