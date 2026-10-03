import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/appointment.dart';
import '../workflow/appointment_event.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, Appointment>> createAppointment({
    int? memberId,
    int? businessId,
    required int packageId,
    required int packagePriceId,
    required String clientFirstName,
    required String clientLastName,
    required DateTime appointmentDate,
    required double priceAtBooking,
    required double depositAmount,
    required double remainingAmount,
    required double commissionPercentAtBooking,
    required double commissionAmountAtBooking,
  });

  Future<Either<Failure, List<Appointment>>> getMyAppointments({String? status});

  Future<Either<Failure, List<Appointment>>> getAppointmentsForBusiness({
    required int businessId,
    String? status,
  });

  Future<Either<Failure, Appointment>> getAppointmentById({
    required int businessId,
    required int appointmentId,
  });

  /// NOTE: AppointmentUpdate's schema marks every field required, contradicting
  /// "partial update" — we send only the non-null args regardless, since that's
  /// clearly the intent; this is a backend schema bug, not a client bug.
  Future<Either<Failure, Appointment>> updateAppointment({
    required int businessId,
    required int appointmentId,
    String? clientFirstName,
    String? clientLastName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    String? appointmentLocation,
    String? appointmentDuration,
    String? appointmentNote,
    int? numberOfPersons,
    String? privacyOptOut,
    String? addsOns,
    int? memberId,
  });

  Future<Either<Failure, void>> deleteAppointment(int appointmentId);

  /// Status changes only go through events; the backend decides legality.
  Future<Either<Failure, Appointment>> fireAppointmentEvent({
    required int businessId,
    required int appointmentId,
    required AppointmentEvent event,
  });
}
