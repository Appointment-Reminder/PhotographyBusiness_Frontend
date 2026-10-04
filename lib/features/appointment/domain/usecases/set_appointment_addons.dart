import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class SetAppointmentAddons extends Usecase<Appointment, SetAppointmentAddonsParams> {
  final AppointmentRepository repository;
  SetAppointmentAddons({required this.repository});

  @override
  Future<Either<Failure, Appointment>> call(SetAppointmentAddonsParams params) {
    return repository.setAppointmentAddons(
      businessId: params.businessId,
      appointmentId: params.appointmentId,
      desired: params.desired,
    );
  }
}
