import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class UpdateAppointment extends Usecase<Appointment, UpdateAppointmentParams> {
  final AppointmentRepository repository;

  UpdateAppointment({required this.repository});

  @override
  Future<Either<Failure, Appointment>> call(UpdateAppointmentParams params) {
    // At least one field must be provided
    if (params.clientName == null &&
        params.clientEmail == null &&
        params.clientPhone == null &&
        params.appointmentDate == null &&
        params.userId == null) {
      return Future.value(Left(ServerFailure('At least one field must be provided')));
    }

    return repository.updateAppointment(
      businessId: params.businessId,
      appointmentId: params.appointmentId,
      clientName: params.clientName,
      clientEmail: params.clientEmail,
      clientPhone: params.clientPhone,
      appointmentDate: params.appointmentDate,
      userId: params.userId,
    );
  }
}