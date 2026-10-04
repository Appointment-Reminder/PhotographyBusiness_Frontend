import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class FireAppointmentEvent
    extends Usecase<Appointment, FireAppointmentEventParams> {
  final AppointmentRepository repository;
  FireAppointmentEvent({required this.repository});

  @override
  Future<Either<Failure, Appointment>> call(FireAppointmentEventParams params) {
    return repository.fireAppointmentEvent(
      businessId: params.businessId,
      appointmentId: params.appointmentId,
      event: params.event,
    );
  }
}
