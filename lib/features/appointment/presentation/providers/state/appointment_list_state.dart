import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment.dart';

class AppointmentListState extends Equatable {
  final List<Appointment> appointments;
  final bool isLoading;
  final String? error;

  /// Failed card actions the user must see on the card itself, keyed by
  /// appointment id (e.g. `assign` failing after the member PATCH saved).
  final Map<int, String> cardErrors;

  const AppointmentListState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
    this.cardErrors = const {},
  });

  AppointmentListState copyWith({
    List<Appointment>? appointments,
    bool? isLoading,
    String? error,
    Map<int, String>? cardErrors,
  }) =>
      AppointmentListState(
        appointments: appointments ?? this.appointments,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        cardErrors: cardErrors ?? this.cardErrors,
      );

  @override
  List<Object?> get props => [appointments, isLoading, error, cardErrors];
}
