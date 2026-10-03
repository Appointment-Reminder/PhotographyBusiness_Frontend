import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/usecases/get_my_appointments.dart';
import '../../../domain/usecases/get_appointments_for_business.dart';
import '../../../domain/usecases/delete_appointment.dart';
import '../../../domain/usecases/appointment_params.dart';
import '../../../domain/usecases/fire_appointment_event.dart';
import '../../../domain/workflow/appointment_event.dart';
import '../state/appointment_list_state.dart';

class AppointmentListNotifier extends StateNotifier<AppointmentListState> {
  final GetMyAppointments getMyAppointments;
  final GetAppointmentsForBusiness getAppointmentsForBusiness;
  final DeleteAppointment deleteAppointment;
  final FireAppointmentEvent fireAppointmentEvent;

  AppointmentListNotifier({
    required this.getMyAppointments,
    required this.getAppointmentsForBusiness,
    required this.deleteAppointment,
    required this.fireAppointmentEvent,
  }) : super(const AppointmentListState());

  Future<void> loadMine({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getMyAppointments(GetMyAppointmentsParams(status: status));
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (list) => state = state.copyWith(isLoading: false, appointments: list),
    );
  }

  Future<void> loadForBusiness(int businessId, {String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getAppointmentsForBusiness(
      GetAppointmentsForBusinessParams(businessId: businessId, status: status),
    );
    result.fold(
      (f) => state = state.copyWith(isLoading: false, error: f.message),
      (list) => state = state.copyWith(isLoading: false, appointments: list),
    );
  }

  /// Optimistic remove; reverts on failure.
  Future<bool> remove(int appointmentId) async {
    final previous = state.appointments;
    state = state.copyWith(
      appointments: previous.where((a) => a.id != appointmentId).toList(),
    );
    final result = await deleteAppointment(DeleteAppointmentParams(appointmentId));
    return result.fold((f) {
      state = state.copyWith(appointments: previous, error: f.message);
      return false;
    }, (_) => true);
  }

  /// Fires an Appointment Event. The card moves optimistically to the event's
  /// resulting status; on failure only that card's status is rolled back.
  /// Returns null on success, or the error message (for a snackbar).
  Future<String?> fireEvent({
    required int businessId,
    required int appointmentId,
    required AppointmentEvent event,
  }) async {
    final index = state.appointments.indexWhere((a) => a.id == appointmentId);
    if (index < 0) return 'Appointment not found';
    final previousStatus = state.appointments[index].status;
    _replace(appointmentId, (a) => a.copyWith(status: event.resultingStatus));

    final result = await fireAppointmentEvent(FireAppointmentEventParams(
      businessId: businessId,
      appointmentId: appointmentId,
      event: event,
    ));
    return result.fold((f) {
      _replace(appointmentId, (a) => a.copyWith(status: previousStatus));
      return f.message;
    }, (updated) {
      _replace(appointmentId, (_) => updated);
      return null;
    });
  }

  void _replace(int id, Appointment Function(Appointment) change) {
    state = state.copyWith(
      appointments: [
        for (final a in state.appointments) a.id == id ? change(a) : a,
      ],
    );
  }
}
