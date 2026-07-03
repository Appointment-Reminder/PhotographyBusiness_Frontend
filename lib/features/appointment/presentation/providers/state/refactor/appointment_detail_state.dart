// appointment_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';

class AppointmentDetailState extends Equatable {
  final Appointment? appointment;
  final bool isLoading;
  final String? error;

  const AppointmentDetailState({this.appointment, this.isLoading = false, this.error});

  AppointmentDetailState copyWith({Appointment? appointment, bool? isLoading, String? error}) =>
      AppointmentDetailState(
        appointment: appointment ?? this.appointment,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [appointment, isLoading, error];
}