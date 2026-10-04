import 'package:equatable/equatable.dart';

/// Mirrors AppointmentRead. `id` is typed nullable in the schema (looks like
/// a backend slip — a persisted appointment always has one) so we coerce
/// defensively rather than crash the whole list on one bad row.
class Appointment extends Equatable {
  final int id;
  final int businessId;
  final int? memberId; // assumed = BusinessMember.id, see README
  final int? formId;
  final int? packageId;
  final int? packagePriceId;
  final String clientFirstName;
  final String clientLastName;
  final String? clientPhone;
  final String? clientEmail;
  final double? priceAtBooking;
  final double? depositAmount;
  final double? remainingAmount;
  final double? commissionPercentAtBooking;
  final double? commissionAmountAtBooking;
  final DateTime appointmentDate;
  final String? appointmentLocation;
  final int? appointmentDuration;
  final String? appointmentNote;
  final int? numberOfPersons;
  final String? privacyOptOut;
  final String? addsOns;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Appointment({
    required this.id,
    required this.businessId,
    this.memberId,
    required this.formId,
    this.packageId,
    this.packagePriceId,
    required this.clientFirstName,
    required this.clientLastName,
    this.clientPhone,
    this.clientEmail,
    this.priceAtBooking,
    this.depositAmount,
    this.remainingAmount,
    this.commissionPercentAtBooking,
    this.commissionAmountAtBooking,
    required this.appointmentDate,
    this.appointmentLocation,
    this.appointmentDuration,
    this.appointmentNote,
    this.numberOfPersons,
    this.privacyOptOut,
    this.addsOns,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  Appointment copyWith({String? status}) => Appointment(
        id: id,
        businessId: businessId,
        memberId: memberId,
        formId: formId,
        packageId: packageId,
        packagePriceId: packagePriceId,
        clientFirstName: clientFirstName,
        clientLastName: clientLastName,
        clientPhone: clientPhone,
        clientEmail: clientEmail,
        priceAtBooking: priceAtBooking,
        depositAmount: depositAmount,
        remainingAmount: remainingAmount,
        commissionPercentAtBooking: commissionPercentAtBooking,
        commissionAmountAtBooking: commissionAmountAtBooking,
        appointmentDate: appointmentDate,
        appointmentLocation: appointmentLocation,
        appointmentDuration: appointmentDuration,
        appointmentNote: appointmentNote,
        numberOfPersons: numberOfPersons,
        privacyOptOut: privacyOptOut,
        addsOns: addsOns,
        status: status ?? this.status,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  String get clientName => '$clientFirstName $clientLastName'.trim();

  @override
  List<Object?> get props => [
        id,
        businessId,
        memberId,
        formId,
        packageId,
        packagePriceId,
        clientFirstName,
        clientLastName,
        clientPhone,
        clientEmail,
        priceAtBooking,
        depositAmount,
        remainingAmount,
        commissionPercentAtBooking,
        commissionAmountAtBooking,
        appointmentDate,
        appointmentLocation,
        appointmentDuration,
        appointmentNote,
        numberOfPersons,
        privacyOptOut,
        addsOns,
        status,
        createdAt,
        updatedAt,
      ];
}
