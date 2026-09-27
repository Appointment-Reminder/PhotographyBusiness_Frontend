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
    if (params.clientFirstName.trim().isEmpty || params.clientLastName.trim().isEmpty) {
      return Future.value(const Left(ServerFailure('Client first and last name are required')));
    }
    return repository.createAppointment(
      memberId: params.memberId,
      businessId: params.businessId,
      packageId: params.packageId,
      packagePriceId: params.packagePriceId,
      clientFirstName: params.clientFirstName,
      clientLastName: params.clientLastName,
      appointmentDate: params.appointmentDate,
      priceAtBooking: params.priceAtBooking,
      depositAmount: params.depositAmount,
      remainingAmount: params.remainingAmount,
      commissionPercentAtBooking: params.commissionPercentAtBooking,
      commissionAmountAtBooking: params.commissionAmountAtBooking,
    );
  }
}
