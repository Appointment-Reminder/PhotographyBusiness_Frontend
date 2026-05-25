import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class GetAppointmentsForBusiness extends Usecase<List<Appointment>, GetAppointmentsForBusinessParams> {
  final AppointmentRepository repository;

  GetAppointmentsForBusiness({required this.repository});

  @override
  Future<Either<Failure, List<Appointment>>> call(GetAppointmentsForBusinessParams params) {
    return repository.getAppointmentsForBusiness(
      businessId: params.businessId,
      status: params.status,
    );
  }
}