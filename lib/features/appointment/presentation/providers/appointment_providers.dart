import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:photography_business_frontend/features/appointment/data/datasources/appointment_remote_datasource_impl.dart';
import 'package:photography_business_frontend/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:photography_business_frontend/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/create_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/delete_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_appointment_by_id.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_appointments_for_business.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_my_appointments.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/update_appointment.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/notifiers/appointment_notifier.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/appointment_state.dart';

// Datasource
final appointmentRemoteDataSourceProvider = Provider<AppointmentRemoteDatasource>((ref) {
  return AppointmentRemoteDatasourceImpl(client: ref.read(dioProvider));
});

// Repository
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  return AppointmentRepositoryImpl(
    remoteDatasource: ref.read(appointmentRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use cases
final getMyAppointmentsProvider = Provider<GetMyAppointments>((ref) {
  return GetMyAppointments(repository: ref.read(appointmentRepositoryProvider));
});

final getAppointmentsForBusinessProvider = Provider<GetAppointmentsForBusiness>((ref) {
  return GetAppointmentsForBusiness(repository: ref.read(appointmentRepositoryProvider));
});

final getAppointmentByIdProvider = Provider<GetAppointmentById>((ref) {
  return GetAppointmentById(repository: ref.read(appointmentRepositoryProvider));
});

final createAppointmentProvider = Provider<CreateAppointmentUser>((ref) {
  return CreateAppointmentUser(repository: ref.read(appointmentRepositoryProvider));
});

final updateAppointmentProvider = Provider<UpdateAppointment>((ref) {
  return UpdateAppointment(repository: ref.read(appointmentRepositoryProvider));
});

final deleteAppointmentProvider = Provider<DeleteAppointment>((ref) {
  return DeleteAppointment(repository: ref.read(appointmentRepositoryProvider));
});

// Notifier
final appointmentNotifierProvider = StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
  return AppointmentNotifier(
    getMyAppointments: ref.read(getMyAppointmentsProvider),
    getAppointmentsForBusiness: ref.read(getAppointmentsForBusinessProvider),
    getAppointmentById: ref.read(getAppointmentByIdProvider),
    createAppointment: ref.read(createAppointmentProvider),
    updateAppointment: ref.read(updateAppointmentProvider),
    deleteAppointment: ref.read(deleteAppointmentProvider),
  );
});