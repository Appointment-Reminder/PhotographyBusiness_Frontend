import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/appointment.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, Appointment>> createAppointment({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    required DateTime appointmentDate,
    int? userId,
    int? businessId,
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

  Future<Either<Failure, Appointment>> updateAppointment({
    required int businessId,
    required int appointmentId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    int? userId,
  });

  Future<Either<Failure, void>> deleteAppointment(int appointmentId);
}