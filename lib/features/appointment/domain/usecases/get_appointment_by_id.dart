import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class GetAppointmentById extends Usecase<Appointment, GetAppointmentByIdParams> {
  final AppointmentRepository repository;

  GetAppointmentById({required this.repository});

  @override
  Future<Either<Failure, Appointment>> call(GetAppointmentByIdParams params) {
    return repository.getAppointmentById(
      businessId: params.businessId,
      appointmentId: params.appointmentId,
    );
  }
}