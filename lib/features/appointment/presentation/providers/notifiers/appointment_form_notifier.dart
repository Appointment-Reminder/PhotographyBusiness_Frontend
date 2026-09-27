import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/appointment.dart';
import '../../../domain/usecases/create_appointment.dart';
import '../../../domain/usecases/update_appointment.dart';
import '../../../domain/usecases/appointment_params.dart';
import '../state/appointment_form_state.dart';

class AppointmentFormNotifier extends StateNotifier<AppointmentFormState> {
  final CreateAppointmentUser createAppointment;
  final UpdateAppointment updateAppointment;

  AppointmentFormNotifier({
    required this.createAppointment,
    required this.updateAppointment,
  }) : super(const AppointmentFormState());

  /// Creates the appointment, then — if the user typed an email/phone —
  /// immediately PATCHes them in, since AppointmentCreate has nowhere to put
  /// them. Remove the second call once the backend adds those two fields to
  /// AppointmentCreate directly.
  ///
  /// Either.fold can't have an async right-branch without both branches
  /// sharing a Future<T> return type, so this walks the result manually
  /// instead of chaining fold calls.
  Future<bool> create(CreateAppointmentParams params) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await createAppointment(params);

    Appointment? created;
    String? createError;
    result.fold((f) => createError = f.message, (a) => created = a);

    if (created == null) {
      state = state.copyWith(isSubmitting: false, error: createError);
      return false;
    }

    if (params.clientEmail == null && params.clientPhone == null) {
      state = state.copyWith(isSubmitting: false, saved: created);
      return true;
    }

    final businessId = params.businessId ?? created!.businessId;
    final patchResult = await updateAppointment(UpdateAppointmentParams(
      businessId: businessId,
      appointmentId: created!.id,
      clientName: created!.clientName,
      clientEmail: params.clientEmail,
      clientPhone: params.clientPhone,
    ));

    Appointment? patched;
    String? patchError;
    patchResult.fold((f) => patchError = f.message, (a) => patched = a);

    if (patched == null) {
      // Appointment was created; only the email/phone patch failed.
      state = state.copyWith(
        isSubmitting: false,
        saved: created,
        error: 'Created, but saving email/phone failed: $patchError',
      );
      return true;
    }

    state = state.copyWith(isSubmitting: false, saved: patched);
    return true;
  }

  Future<bool> update({
    required int businessId,
    required int appointmentId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    String? appointmentLocation,
    String? appointmentDuration,
    String? appointmentNote,
    int? numberOfPersons,
    String? privacyOptOut,
    String? addsOns,
    int? memberId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await updateAppointment(UpdateAppointmentParams(
      businessId: businessId,
      appointmentId: appointmentId,
      clientName: clientName,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      appointmentDate: appointmentDate,
      appointmentLocation: appointmentLocation,
      appointmentDuration: appointmentDuration,
      appointmentNote: appointmentNote,
      numberOfPersons: numberOfPersons,
      privacyOptOut: privacyOptOut,
      addsOns: addsOns,
      memberId: memberId,
    ));
    return result.fold((f) {
      state = state.copyWith(isSubmitting: false, error: f.message);
      return false;
    }, (a) {
      state = state.copyWith(isSubmitting: false, saved: a);
      return true;
    });
  }

  void reset() => state = const AppointmentFormState();
}
