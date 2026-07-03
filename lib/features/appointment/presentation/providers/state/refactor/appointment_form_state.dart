// appointment_form_state.dart — create/update/delete
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';

class AppointmentFormState extends Equatable {
  final Appointment? saved;
  final bool isSubmitting;
  final String? error;

  const AppointmentFormState({this.saved, this.isSubmitting = false, this.error});

  AppointmentFormState copyWith({Appointment? saved, bool? isSubmitting, String? error}) =>
      AppointmentFormState(
        saved: saved ?? this.saved,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  @override
  List<Object?> get props => [saved, isSubmitting, error];
}