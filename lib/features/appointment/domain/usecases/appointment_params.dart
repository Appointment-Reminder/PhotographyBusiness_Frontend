import 'package:equatable/equatable.dart';
import '../workflow/appointment_event.dart';

class CreateAppointmentParams extends Equatable {
  final int? memberId;
  final int? businessId;
  final int packageId;
  final int packagePriceId;
  final String clientFirstName;
  final String clientLastName;
  // Not accepted by AppointmentCreate today — carried here so the notifier
  // can fire a follow-up PATCH right after creation. Drop this once the
  // backend adds client_email/client_phone to AppointmentCreate.
  final String? clientEmail;
  final String? clientPhone;
  final DateTime appointmentDate;
  final double priceAtBooking;
  final double depositAmount;
  final double remainingAmount;
  final double commissionPercentAtBooking;
  final double commissionAmountAtBooking;
  final String? appointmentLocation;
  final String? appointmentDuration;
  final String? appointmentNote;
  final int? numberOfPersons;
  final String? addsOns;

  const CreateAppointmentParams({
    this.memberId,
    this.businessId,
    required this.packageId,
    required this.packagePriceId,
    required this.clientFirstName,
    required this.clientLastName,
    this.clientEmail,
    this.clientPhone,
    required this.appointmentDate,
    required this.priceAtBooking,
    required this.depositAmount,
    required this.remainingAmount,
    required this.commissionPercentAtBooking,
    required this.commissionAmountAtBooking,
    this.appointmentLocation,
    this.appointmentDuration,
    this.appointmentNote,
    this.numberOfPersons,
    this.addsOns,
  });

  @override
  List<Object?> get props => [
        memberId,
        businessId,
        packageId,
        packagePriceId,
        clientFirstName,
        clientLastName,
        clientEmail,
        clientPhone,
        appointmentDate,
        priceAtBooking,
        depositAmount,
        remainingAmount,
        commissionPercentAtBooking,
        commissionAmountAtBooking,
        appointmentLocation,
        appointmentDuration,
        appointmentNote,
        numberOfPersons,
        addsOns,
      ];
}

class GetMyAppointmentsParams extends Equatable {
  final String? status;
  const GetMyAppointmentsParams({this.status});
  @override
  List<Object?> get props => [status];
}

class GetAppointmentsForBusinessParams extends Equatable {
  final int businessId;
  final String? status;
  const GetAppointmentsForBusinessParams({required this.businessId, this.status});
  @override
  List<Object?> get props => [businessId, status];
}

class GetAppointmentByIdParams extends Equatable {
  final int businessId;
  final int appointmentId;
  const GetAppointmentByIdParams({required this.businessId, required this.appointmentId});
  @override
  List<Object?> get props => [businessId, appointmentId];
}

class UpdateAppointmentParams extends Equatable {
  final int businessId;
  final int appointmentId;
  final String? clientFirstName;
  final String? clientLastName;
  final String? clientEmail;
  final String? clientPhone;
  final DateTime? appointmentDate;
  final String? appointmentLocation;
  final String? appointmentDuration;
  final String? appointmentNote;
  final int? numberOfPersons;
  final String? privacyOptOut;
  final String? addsOns;
  final int? memberId;

  const UpdateAppointmentParams({
    required this.businessId,
    required this.appointmentId,
    this.clientFirstName,
    this.clientLastName,
    this.clientEmail,
    this.clientPhone,
    this.appointmentDate,
    this.appointmentLocation,
    this.appointmentDuration,
    this.appointmentNote,
    this.numberOfPersons,
    this.privacyOptOut,
    this.addsOns,
    this.memberId,
  });

  @override
  List<Object?> get props => [
        businessId,
        appointmentId,
        clientFirstName,
        clientLastName,
        clientEmail,
        clientPhone,
        appointmentDate,
        appointmentLocation,
        appointmentDuration,
        appointmentNote,
        numberOfPersons,
        privacyOptOut,
        addsOns,
        memberId,
      ];
}

class DeleteAppointmentParams extends Equatable {
  final int appointmentId;
  const DeleteAppointmentParams(this.appointmentId);
  @override
  List<Object?> get props => [appointmentId];
}

class FireAppointmentEventParams extends Equatable {
  final int businessId;
  final int appointmentId;
  final AppointmentEvent event;
  const FireAppointmentEventParams({
    required this.businessId,
    required this.appointmentId,
    required this.event,
  });
  @override
  List<Object?> get props => [businessId, appointmentId, event];
}


class SetAppointmentAddonsParams extends Equatable {
  final int businessId;
  final int appointmentId;

  /// Add-on id to quantity; zero or absent means not selected.
  final Map<int, int> desired;

  const SetAppointmentAddonsParams({
    required this.businessId,
    required this.appointmentId,
    required this.desired,
  });

  @override
  List<Object?> get props => [businessId, appointmentId, desired];
}

class ResolveUnresolvedAddonParams extends Equatable {
  final int businessId;
  final int appointmentId;
  final int unresolvedId;
  final int addonId;
  final int quantity;

  const ResolveUnresolvedAddonParams({
    required this.businessId,
    required this.appointmentId,
    required this.unresolvedId,
    required this.addonId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [businessId, appointmentId, unresolvedId, addonId, quantity];
}
