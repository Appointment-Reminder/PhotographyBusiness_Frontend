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
    final hasAnyField = params.clientFirstName != null ||
        params.clientLastName != null ||
        params.clientEmail != null ||
        params.clientPhone != null ||
        params.appointmentDate != null ||
        params.appointmentLocation != null ||
        params.appointmentDuration != null ||
        params.appointmentNote != null ||
        params.numberOfPersons != null ||
        params.privacyOptOut != null ||
        params.addsOns != null ||
        params.memberId != null;
    if (!hasAnyField) {
      return Future.value(const Left(ServerFailure('At least one field must be provided')));
    }
    return repository.updateAppointment(
      businessId: params.businessId,
      appointmentId: params.appointmentId,
      clientFirstName: params.clientFirstName,
      clientLastName: params.clientLastName,
      clientEmail: params.clientEmail,
      clientPhone: params.clientPhone,
      appointmentDate: params.appointmentDate,
      appointmentLocation: params.appointmentLocation,
      appointmentDuration: params.appointmentDuration,
      appointmentNote: params.appointmentNote,
      numberOfPersons: params.numberOfPersons,
      privacyOptOut: params.privacyOptOut,
      addsOns: params.addsOns,
      memberId: params.memberId,
    );
  }
}
