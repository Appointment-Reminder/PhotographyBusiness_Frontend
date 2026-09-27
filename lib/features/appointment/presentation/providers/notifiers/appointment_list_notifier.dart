import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/get_my_appointments.dart';
import '../../../domain/usecases/get_appointments_for_business.dart';
import '../../../domain/usecases/delete_appointment.dart';
import '../../../domain/usecases/appointment_params.dart';
import '../state/appointment_list_state.dart';

class AppointmentListNotifier extends StateNotifier<AppointmentListState> {
  final GetMyAppointments getMyAppointments;
  final GetAppointmentsForBusiness getAppointmentsForBusiness;
  final DeleteAppointment deleteAppointment;

  AppointmentListNotifier({
    required this.getMyAppointments,
    required this.getAppointmentsForBusiness,
    required this.deleteAppointment,
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
}
