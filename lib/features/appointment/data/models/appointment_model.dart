import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_addon.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.businessId,
    super.memberId,
    super.formId,
    super.packageId,
    super.packagePriceId,
    required super.clientFirstName,
    required super.clientLastName,
    super.clientPhone,
    super.clientEmail,
    super.priceAtBooking,
    super.depositAmount,
    super.remainingAmount,
    super.commissionPercentAtBooking,
    super.commissionAmountAtBooking,
    required super.appointmentDate,
    super.appointmentLocation,
    super.appointmentDuration,
    super.appointmentNote,
    super.numberOfPersons,
    super.privacyOptOut,
    super.addsOns,
    super.addons,
    super.unresolvedAddons,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  static double? _num(dynamic v) => v == null ? null : (v as num).toDouble();

  static AppointmentAddon _addon(Map<String, dynamic> j) => AppointmentAddon(
        id: j['id'],
        addonId: j['addon_id'],
        addonPriceId: j['addon_price_id'] ?? 0,
        quantity: j['quantity'],
        unitPrice: _num(j['unit_price']) ?? 0,
        unitDuration: j['unit_duration'] ?? 0,
        priceTotal: _num(j['price_total']) ?? 0,
        commissionTotal: _num(j['commission_total']),
        rawLabel: j['raw_label'],
      );

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      // AppointmentRead types `id` as nullable — treating a missing id as 0
      // rather than crashing the whole list; this should never happen for a
      // persisted row, flag it backend-side if it ever does.
      id: json['id'] ?? 0,
      businessId: json['business_id'],
      memberId: json['member_id'],
      formId: json['form_id'],
      packageId: json['package_id'],
      packagePriceId: json['package_price_id'],
      clientFirstName: json['client_first_name'],
      clientLastName: json['client_last_name'],
      clientPhone: json['client_phone'],
      clientEmail: json['client_email'],
      priceAtBooking: _num(json['price_at_booking']),
      depositAmount: _num(json['deposit_amount']),
      remainingAmount: _num(json['remaining_amount']),
      commissionPercentAtBooking: _num(json['commission_percent_at_booking']),
      commissionAmountAtBooking: _num(json['commission_amount_at_booking']),
      appointmentDate: DateTime.parse(json['appointment_date']),
      appointmentLocation: json['appointment_location'],
      appointmentDuration: json['appointment_duration'],
      appointmentNote: json['appointment_note'],
      numberOfPersons: json['number_of_persons'],
      privacyOptOut: json['privacy_opt_out'],
      addsOns: json['adds_ons'],
      addons: [for (final a in (json['addons'] as List? ?? [])) _addon(a)],
      unresolvedAddons: [
        for (final u in (json['unresolved_addons'] as List? ?? []))
          UnresolvedAddon(id: u['id'], rawLabel: u['raw_label']),
      ],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
