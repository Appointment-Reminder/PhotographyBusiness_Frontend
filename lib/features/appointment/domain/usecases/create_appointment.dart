import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class CreateAppointmentUser extends Usecase<Appointment, CreateAppointmentParams> {
  final AppointmentRepository repository;

  CreateAppointmentUser({required this.repository});

  @override
  Future<Either<Failure, Appointment>> call(CreateAppointmentParams params) {
    if (params.clientName.isEmpty) {
      return Future.value(Left(ServerFailure('Client name is required')));
    }
    if (params.clientEmail.isEmpty) {
      return Future.value(Left(ServerFailure('Client email is required')));
    }

    if(params.businessId.isNaN){
      return Future.value(Left(ServerFailure('Business id is required')));
    }

    if(params.userId.isNaN){
      return Future.value(Left(ServerFailure('User id is required')));
    }

    return repository.createAppointment(
      clientName: params.clientName,
      clientEmail: params.clientEmail,
      clientPhone: params.clientPhone,
      appointmentDate: params.appointmentDate,
      userId: params.userId,
      businessId: params.businessId,
    );
  }
}