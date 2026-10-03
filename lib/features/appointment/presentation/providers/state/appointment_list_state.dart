import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment.dart';

class AppointmentListState extends Equatable {
  final List<Appointment> appointments;
  final bool isLoading;
  final String? error;

  const AppointmentListState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
  });

  AppointmentListState copyWith({
    List<Appointment>? appointments,
    bool? isLoading,
    String? error,
  }) =>
      AppointmentListState(
        appointments: appointments ?? this.appointments,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [appointments, isLoading, error];
}
