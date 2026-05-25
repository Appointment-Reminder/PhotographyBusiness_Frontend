import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class GetMyAppointments extends Usecase<List<Appointment>, GetMyAppointmentsParams> {
  final AppointmentRepository repository;

  GetMyAppointments({required this.repository});

  @override
  Future<Either<Failure, List<Appointment>>> call(GetMyAppointmentsParams params) {
    return repository.getMyAppointments(status: params.status);
  }
}