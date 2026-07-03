// appointment_list_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/refactor/appointment_list_state.dart';
import '../../../domain/usecases/get_my_appointments.dart';
import '../../../domain/usecases/get_appointments_for_business.dart';
import '../../../domain/usecases/appointment_params.dart';

class AppointmentListNotifier extends StateNotifier<AppointmentListState> {
  final GetMyAppointments getMyAppointments;
  final GetAppointmentsForBusiness getAppointmentsForBusiness;

  AppointmentListNotifier({
    required this.getMyAppointments,
    required this.getAppointmentsForBusiness,
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
}