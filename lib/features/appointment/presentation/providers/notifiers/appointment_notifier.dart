import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/create_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/delete_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_appointment_by_id.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_appointments_for_business.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_my_appointments.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/update_appointment.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/state/appointment_state.dart';

import '../../../domain/usecases/appointment_params.dart';

class AppointmentNotifier extends StateNotifier<AppointmentState> {
  final GetMyAppointments getMyAppointments;
  final GetAppointmentsForBusiness getAppointmentsForBusiness;
  final GetAppointmentById getAppointmentById;
  final CreateAppointmentUser createAppointment;
  final UpdateAppointment updateAppointment;
  final DeleteAppointment deleteAppointment;

  AppointmentNotifier({
    required this.getMyAppointments,
    required this.getAppointmentsForBusiness,
    required this.getAppointmentById,
    required this.createAppointment,
    required this.updateAppointment,
    required this.deleteAppointment,
  }) : super(const AppointmentInitial());

  /// Load all appointments (across all businesses)
  Future<void> loadMyAppointments({String? status}) async {
    state = const AppointmentLoading();

    final result = await getMyAppointments(GetMyAppointmentsParams(status: status));

    result.fold(
          (failure) => state = AppointmentError(message: failure.message),
          (appointments) => state = AppointmentListLoaded(appointments: appointments),
    );
  }

  /// Load appointments for a specific business
  Future<void> loadAppointmentsForBusiness({
    required int businessId,
    String? status,
  }) async {
    state = const AppointmentLoading();

    final result = await getAppointmentsForBusiness(
      GetAppointmentsForBusinessParams(businessId: businessId, status: status),
    );

    result.fold(
          (failure) => state = AppointmentError(message: failure.message),
          (appointments) => state = AppointmentListLoaded(appointments: appointments),
    );
  }

  /// Load a single appointment by ID
  Future<void> loadAppointmentById({
    required int businessId,
    required int appointmentId,
  }) async {
    state = const AppointmentLoading();

    final result = await getAppointmentById(
      GetAppointmentByIdParams(businessId: businessId, appointmentId: appointmentId),
    );

    result.fold(
          (failure) => state = AppointmentError(message: failure.message),
          (appointment) => state = AppointmentDetailLoaded(appointment: appointment),
    );
  }

  /// Create a new appointment
  Future<void> createNewAppointment({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    required DateTime appointmentDate,
    required int userId,
    required int businessId,
  }) async {
    state = const AppointmentLoading();

    final result = await createAppointment(
      CreateAppointmentParams(
        clientName: clientName,
        clientEmail: clientEmail,
        clientPhone: clientPhone,
        appointmentDate: appointmentDate,
        userId: userId,
        businessId: businessId,
      ),
    );

    result.fold(
          (failure) => state = AppointmentError(message: failure.message),
          (appointment) => state = AppointmentDetailLoaded(appointment: appointment),
    );
  }

  /// Update an existing appointment
  Future<void> updateExistingAppointment({
    required int businessId,
    required int appointmentId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    int? userId,
  }) async {
    state = const AppointmentLoading();

    final result = await updateAppointment(
      UpdateAppointmentParams(
        businessId: businessId,
        appointmentId: appointmentId,
        clientName: clientName,
        clientEmail: clientEmail,
        clientPhone: clientPhone,
        appointmentDate: appointmentDate,
        userId: userId,
      ),
    );

    result.fold(
          (failure) => state = AppointmentError(message: failure.message),
          (appointment) => state = AppointmentDetailLoaded(appointment: appointment),
    );
  }

  /// Delete an appointment
  Future<void> deleteAppointmentById(int appointmentId) async {
    state = const AppointmentLoading();

    final result = await deleteAppointment(DeleteAppointmentParams(appointmentId));

    result.fold(
          (failure) => state = AppointmentError(message: failure.message),
          (_) => state = const AppointmentInitial(),
    );
  }
}