import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment.dart';

abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

class AppointmentListLoaded extends AppointmentState {
  final List<Appointment> appointments;

  const AppointmentListLoaded({required this.appointments});

  @override
  List<Object?> get props => [appointments];
}

class AppointmentDetailLoaded extends AppointmentState {
  final Appointment appointment;

  const AppointmentDetailLoaded({required this.appointment});

  @override
  List<Object?> get props => [appointment];
}

class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError({required this.message});

  @override
  List<Object?> get props => [message];
}