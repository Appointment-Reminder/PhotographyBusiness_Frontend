import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/appointment.dart';
import '../repositories/appointment_repository.dart';
import 'appointment_params.dart';

class ResolveUnresolvedAddon extends Usecase<Appointment, ResolveUnresolvedAddonParams> {
  final AppointmentRepository repository;
  ResolveUnresolvedAddon({required this.repository});

  @override
  Future<Either<Failure, Appointment>> call(ResolveUnresolvedAddonParams params) {
    return repository.resolveUnresolvedAddon(
      businessId: params.businessId,
      appointmentId: params.appointmentId,
      unresolvedId: params.unresolvedId,
      addonId: params.addonId,
      quantity: params.quantity,
    );
  }
}
