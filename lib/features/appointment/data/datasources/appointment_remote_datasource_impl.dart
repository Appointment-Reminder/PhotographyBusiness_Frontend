import 'package:dio/dio.dart';
import 'package:photography_business_frontend/features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:photography_business_frontend/features/appointment/data/models/appointment_model.dart';
import '../../domain/entities/appointment.dart';

class AppointmentRemoteDatasourceImpl implements AppointmentRemoteDatasource {
  final Dio client;

  AppointmentRemoteDatasourceImpl({required this.client});

  @override
  Future<Appointment> createAppointment({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    required DateTime appointmentDate,
    required int userId,
    required int businessId,
  }) async {
    final response = await client.post(
      '/appointments/appointments',
      data: {
        'client_name': clientName,
        'client_email': clientEmail,
        if (clientPhone != null) 'client_phone': clientPhone,
        'appointment_date': appointmentDate.toIso8601String(),
        'user_id': userId,
        'business_id': businessId,
      },
    );

    return AppointmentModel.fromJson(response.data);
  }

  @override
  Future<List<Appointment>> getMyAppointments({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await client.get(
      '/appointments/me',
      queryParameters: queryParams,
    );

    final List<dynamic> appointmentList = response.data;
    return appointmentList
        .map((json) => AppointmentModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<Appointment>> getAppointmentsForBusiness({
    required int businessId,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await client.get(
      '/appointments/business/$businessId',
      queryParameters: queryParams,
    );

    final List<dynamic> appointmentList = response.data;
    return appointmentList
        .map((json) => AppointmentModel.fromJson(json))
        .toList();
  }

  @override
  Future<Appointment> getAppointmentById({
    required int businessId,
    required int appointmentId,
  }) async {
    final response = await client.get(
      '/appointments/business/$businessId/appointments/$appointmentId',
    );

    return AppointmentModel.fromJson(response.data);
  }

  @override
  Future<Appointment> updateAppointment({
    required int businessId,
    required int appointmentId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    int? userId,
  }) async {
    final response = await client.patch(
      '/appointments/business/$businessId/appointments/$appointmentId',
      data: {
        if (clientName != null) 'client_name': clientName,
        if (clientEmail != null) 'client_email': clientEmail,
        if (clientPhone != null) 'client_phone': clientPhone,
        if (appointmentDate != null) 'appointment_date': appointmentDate.toIso8601String(),
        if (userId != null) 'user_id': userId,
      },
    );

    return AppointmentModel.fromJson(response.data);
  }

  @override
  Future<void> deleteAppointment(int appointmentId) async {
    await client.delete('/appointments/$appointmentId');
  }
}