// appointment_form_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/refactor/appointment_form_state.dart';
import '../../../domain/usecases/create_appointment.dart';
import '../../../domain/usecases/update_appointment.dart';
import '../../../domain/usecases/delete_appointment.dart';
import '../../../domain/usecases/appointment_params.dart';

class AppointmentFormNotifier extends StateNotifier<AppointmentFormState> {
  final CreateAppointmentUser createAppointment;
  final UpdateAppointment updateAppointment;
  final DeleteAppointment deleteAppointment;

  AppointmentFormNotifier({
    required this.createAppointment,
    required this.updateAppointment,
    required this.deleteAppointment,
  }) : super(const AppointmentFormState());

  Future<void> create({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    required DateTime appointmentDate,
    required int userId,
    required int businessId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await createAppointment(CreateAppointmentParams(
      clientName: clientName,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      appointmentDate: appointmentDate,
      userId: userId,
      businessId: businessId,
    ));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (a) => state = state.copyWith(isSubmitting: false, saved: a),
    );
  }

  Future<void> update({
    required int businessId,
    required int appointmentId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    int? userId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await updateAppointment(UpdateAppointmentParams(
      businessId: businessId,
      appointmentId: appointmentId,
      clientName: clientName,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      appointmentDate: appointmentDate,
      userId: userId,
    ));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (a) => state = state.copyWith(isSubmitting: false, saved: a),
    );
  }

  Future<bool> delete(int appointmentId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await deleteAppointment(DeleteAppointmentParams(appointmentId));
    return result.fold(
          (f) {
        state = state.copyWith(isSubmitting: false, error: f.message);
        return false;
      },
          (_) {
        state = state.copyWith(isSubmitting: false);
        return true;
      },
    );
  }
}