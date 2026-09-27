import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.businessId,
    super.memberId,
    required super.formId,
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
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  static double? _num(dynamic v) => v == null ? null : (v as num).toDouble();

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
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
