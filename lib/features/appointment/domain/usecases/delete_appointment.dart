import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class DeleteAppointment extends Usecase<void, DeleteAppointmentParams> {
  final AppointmentRepository repository;

  DeleteAppointment({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteAppointmentParams params) {
    return repository.deleteAppointment(params.appointmentId);
  }
}