import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/usecases/get_my_appointments.dart';
import '../../../domain/usecases/get_appointments_for_business.dart';
import '../../../domain/usecases/delete_appointment.dart';
import '../../../domain/usecases/appointment_params.dart';
import '../../../domain/usecases/fire_appointment_event.dart';
import '../../../domain/usecases/update_appointment.dart';
import '../../../domain/workflow/appointment_event.dart';
import '../state/appointment_list_state.dart';

class AppointmentListNotifier extends StateNotifier<AppointmentListState> {
  final GetMyAppointments getMyAppointments;
  final GetAppointmentsForBusiness getAppointmentsForBusiness;
  final DeleteAppointment deleteAppointment;
  final FireAppointmentEvent fireAppointmentEvent;
  final UpdateAppointment updateAppointment;

  AppointmentListNotifier({
    required this.getMyAppointments,
    required this.getAppointmentsForBusiness,
    required this.deleteAppointment,
    required this.fireAppointmentEvent,
    required this.updateAppointment,
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

  /// Cards with an event request in flight. A second event on the same card
  /// is refused, so a rollback always restores the last server-confirmed
  /// status.
  final Set<int> _eventsInFlight = {};

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
    if (!_eventsInFlight.add(appointmentId)) {
      return 'Another change to this appointment is still in progress';
    }
    final previousStatus = state.appointments[index].status;
    _replace(appointmentId, (a) => a.copyWith(status: event.resultingStatus));

    try {
      final error = await _commit(
        appointmentId,
        fireAppointmentEvent(FireAppointmentEventParams(
          businessId: businessId,
          appointmentId: appointmentId,
          event: event,
        )),
      );
      if (error != null) {
        _replace(appointmentId, (a) => a.copyWith(status: previousStatus));
      }
      return error;
    } finally {
      _eventsInFlight.remove(appointmentId);
    }
  }

  /// Reassigns an Appointment: PATCH `member_id` only, no event, status
  /// unchanged. Returns null on success, or the error message.
  Future<String?> reassign({
    required int businessId,
    required int appointmentId,
    required int memberId,
  }) =>
      _commit(
        appointmentId,
        updateAppointment(UpdateAppointmentParams(
          businessId: businessId,
          appointmentId: appointmentId,
          memberId: memberId,
        )),
      );

  /// Assigns a Needs Assignment Appointment: PATCH `member_id`, then fires
  /// `assign`. If the PATCH fails no event is fired. If `assign` fails after
  /// the PATCH, the card stays in its column (member already saved) and
  /// carries the error in [AppointmentListState.cardErrors].
  /// Returns null on success, or the error message.
  Future<String?> assignAndSchedule({
    required int businessId,
    required int appointmentId,
    required int memberId,
  }) async {
    final patchError = await reassign(
      businessId: businessId,
      appointmentId: appointmentId,
      memberId: memberId,
    );
    if (patchError != null) return patchError;
    final eventError = await fireEvent(
      businessId: businessId,
      appointmentId: appointmentId,
      event: AppointmentEvent.assign,
    );
    if (eventError != null) {
      state = state.copyWith(
        cardErrors: {...state.cardErrors, appointmentId: eventError},
      );
    }
    return eventError;
  }

  /// Applies a server response for one card: replaces it on success (and
  /// clears its card error), returns the failure message otherwise.
  Future<String?> _commit(
    int appointmentId,
    Future<Either<Failure, Appointment>> request,
  ) async {
    final result = await request;
    return result.fold((f) => f.message, (updated) {
      _replace(appointmentId, (_) => updated);
      if (state.cardErrors.containsKey(appointmentId)) {
        state = state.copyWith(
          cardErrors: {...state.cardErrors}..remove(appointmentId),
        );
      }
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
