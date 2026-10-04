import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';

import '../../data/datasources/appointment_remote_datasource.dart';
import '../../data/datasources/appointment_remote_datasource_impl.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/usecases/create_appointment.dart';
import '../../domain/usecases/delete_appointment.dart';
import '../../domain/usecases/fire_appointment_event.dart';
import '../../domain/usecases/get_appointment_by_id.dart';
import '../../domain/usecases/get_appointments_for_business.dart';
import '../../domain/usecases/get_my_appointments.dart';
import '../../domain/usecases/update_appointment.dart';
import 'notifiers/appointment_form_notifier.dart';
import 'notifiers/appointment_list_notifier.dart';
import 'state/appointment_form_state.dart';
import 'state/appointment_list_state.dart';

final appointmentRemoteDataSourceProvider = Provider<AppointmentRemoteDatasource>((ref) {
  return AppointmentRemoteDatasourceImpl(client: ref.read(dioProvider));
});

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(
    remoteDatasource: ref.read(appointmentRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final createAppointmentUserProvider = Provider<CreateAppointmentUser>((ref) {
  return CreateAppointmentUser(repository: ref.read(appointmentRepositoryProvider));
});

final getMyAppointmentsProvider = Provider<GetMyAppointments>((ref) {
  return GetMyAppointments(repository: ref.read(appointmentRepositoryProvider));
});

final getAppointmentsForBusinessProvider = Provider<GetAppointmentsForBusiness>((ref) {
  return GetAppointmentsForBusiness(repository: ref.read(appointmentRepositoryProvider));
});

final getAppointmentByIdProvider = Provider<GetAppointmentById>((ref) {
  return GetAppointmentById(repository: ref.read(appointmentRepositoryProvider));
});

final updateAppointmentProvider = Provider<UpdateAppointment>((ref) {
  return UpdateAppointment(repository: ref.read(appointmentRepositoryProvider));
});

final deleteAppointmentProvider = Provider<DeleteAppointment>((ref) {
  return DeleteAppointment(repository: ref.read(appointmentRepositoryProvider));
});

final fireAppointmentEventProvider = Provider<FireAppointmentEvent>((ref) {
  return FireAppointmentEvent(repository: ref.read(appointmentRepositoryProvider));
});

/// Keyed by businessId so switching business doesn't leak state — same
/// pattern as businessMembersProvider.
final appointmentListNotifierProvider = StateNotifierProvider.family<
    AppointmentListNotifier, AppointmentListState, int>((ref, businessId) {
  final notifier = AppointmentListNotifier(
    getMyAppointments: ref.read(getMyAppointmentsProvider),
    getAppointmentsForBusiness: ref.read(getAppointmentsForBusinessProvider),
    deleteAppointment: ref.read(deleteAppointmentProvider),
    fireAppointmentEvent: ref.read(fireAppointmentEventProvider),
    updateAppointment: ref.read(updateAppointmentProvider),
  );
  notifier.loadForBusiness(businessId);
  return notifier;
});

final appointmentFormNotifierProvider =
    StateNotifierProvider<AppointmentFormNotifier, AppointmentFormState>((ref) {
  return AppointmentFormNotifier(
    createAppointment: ref.read(createAppointmentUserProvider),
    updateAppointment: ref.read(updateAppointmentProvider),
  );
});

