import 'package:equatable/equatable.dart';

class CreateAppointmentParams extends Equatable {
  final String clientName;
  final String clientEmail;
  final String? clientPhone;
  final DateTime appointmentDate;
  final int userId;
  final int businessId;

  const CreateAppointmentParams({
    required this.clientName,
    required this.clientEmail,
    this.clientPhone,
    required this.appointmentDate,
    required this.userId,
    required this.businessId,
  });

  @override
  List<Object?> get props => [clientName, clientEmail, clientPhone, appointmentDate, userId, businessId];
}

class GetMyAppointmentsParams extends Equatable {
  final String? status;

  const GetMyAppointmentsParams({this.status});

  @override
  List<Object?> get props => [status];
}

class GetAppointmentsForBusinessParams extends Equatable {
  final int businessId;
  final String? status;

  const GetAppointmentsForBusinessParams({
    required this.businessId,
    this.status,
  });

  @override
  List<Object?> get props => [businessId, status];
}

class GetAppointmentByIdParams extends Equatable {
  final int businessId;
  final int appointmentId;

  const GetAppointmentByIdParams({
    required this.businessId,
    required this.appointmentId,
  });

  @override
  List<Object?> get props => [businessId, appointmentId];
}

class UpdateAppointmentParams extends Equatable {
  final int businessId;
  final int appointmentId;
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final DateTime? appointmentDate;
  final int? userId;

  const UpdateAppointmentParams({
    required this.businessId,
    required this.appointmentId,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.appointmentDate,
    this.userId,
  });

  @override
  List<Object?> get props => [businessId, appointmentId, clientName, clientEmail, clientPhone, appointmentDate, userId];
}

class DeleteAppointmentParams extends Equatable {
  final int appointmentId;

  const DeleteAppointmentParams(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}