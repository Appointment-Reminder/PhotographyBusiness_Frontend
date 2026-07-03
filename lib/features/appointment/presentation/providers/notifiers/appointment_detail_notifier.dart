// appointment_detail_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/refactor/appointment_detail_state.dart';
import '../../../domain/usecases/get_appointment_by_id.dart';
import '../../../domain/usecases/appointment_params.dart';


class AppointmentDetailNotifier extends StateNotifier<AppointmentDetailState> {
  final GetAppointmentById getAppointmentById;

  AppointmentDetailNotifier({required this.getAppointmentById}) : super(const AppointmentDetailState());

  Future<void> load({required int businessId, required int appointmentId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getAppointmentById(
      GetAppointmentByIdParams(businessId: businessId, appointmentId: appointmentId),
    );
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (a) => state = state.copyWith(isLoading: false, appointment: a),
    );
  }

  void clear() => state = const AppointmentDetailState();
}