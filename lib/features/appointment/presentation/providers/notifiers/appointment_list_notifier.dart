import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../../../domain/entities/appointment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/get_my_appointments.dart';
import '../../../domain/addons/appointment_addon_editing.dart';
import '../../../domain/usecases/get_appointment_by_id.dart';
import '../../../domain/usecases/get_appointments_for_business.dart';
import '../../../domain/usecases/resolve_unresolved_addon.dart';
import '../../../domain/usecases/set_appointment_addons.dart';
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
  final GetAppointmentById getAppointmentById;
  final SetAppointmentAddons setAppointmentAddons;
  final ResolveUnresolvedAddon resolveUnresolvedAddon;

  AppointmentListNotifier({
    required this.getMyAppointments,
    required this.getAppointmentsForBusiness,
    required this.deleteAppointment,
    required this.fireAppointmentEvent,
    required this.updateAppointment,
    required this.getAppointmentById,
    required this.setAppointmentAddons,
    required this.resolveUnresolvedAddon,
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

  /// Assigns a member to an Appointment: PATCH `member_id` only, no event.
  /// The backend moves a Needs Assignment card to `pending` itself, so the card
  /// takes whatever status the response carries (no optimistic move).
  /// Returns null on success, or the error message.
  Future<String?> assign({
    required int businessId,
    required int appointmentId,
    required int memberId,
  }) async {
    return _commit(
      appointmentId,
      updateAppointment(UpdateAppointmentParams(
        businessId: businessId,
        appointmentId: appointmentId,
        memberId: memberId,
      )),
    );
  }

  /// Saves the Add-on editor's draft (Add-on id to quantity). On the first
  /// failure the Appointment is refetched, so the screen shows what the
  /// backend has, and the error message is returned. Returns null on success.
  Future<String?> setAddons({
    required int businessId,
    required int appointmentId,
    required Map<int, int> desired,
  }) async {
    final index = state.appointments.indexWhere((a) => a.id == appointmentId);
    if (index < 0) return 'Appointment not found';
    if (!AppointmentAddonEditing.canEdit(
        isManager: true, status: state.appointments[index].status)) {
      return 'Add-ons can no longer be changed on this appointment';
    }
    if (!_eventsInFlight.add(appointmentId)) {
      return 'Another change to this appointment is still in progress';
    }
    try {
      final error = await _commit(
        appointmentId,
        setAppointmentAddons(SetAppointmentAddonsParams(
          businessId: businessId,
          appointmentId: appointmentId,
          desired: desired,
        )),
      );
      if (error != null) await _refetch(businessId, appointmentId);
      return error;
    } finally {
      _eventsInFlight.remove(appointmentId);
    }
  }

  /// Resolves an Unresolved Add-on against a catalogue Add-on. The response
  /// replaces the Appointment; on failure nothing changes. Returns null on
  /// success, or the error message.
  Future<String?> resolveAddon({
    required int businessId,
    required int appointmentId,
    required int unresolvedId,
    required int addonId,
    required int quantity,
  }) {
    return _commit(
      appointmentId,
      resolveUnresolvedAddon(ResolveUnresolvedAddonParams(
        businessId: businessId,
        appointmentId: appointmentId,
        unresolvedId: unresolvedId,
        addonId: addonId,
        quantity: quantity,
      )),
    );
  }

  Future<void> _refetch(int businessId, int appointmentId) => _commit(
        appointmentId,
        getAppointmentById(
            GetAppointmentByIdParams(businessId: businessId, appointmentId: appointmentId)),
      );

  /// Replaces one card with the server response, or returns the failure
  /// message.
  Future<String?> _commit(
    int appointmentId,
    Future<Either<Failure, Appointment>> request,
  ) async {
    final result = await request;
    return result.fold((f) => f.message, (updated) {
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
