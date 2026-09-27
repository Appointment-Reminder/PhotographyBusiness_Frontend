import 'package:dio/dio.dart';
import '../models/appointment_model.dart';
import '../../domain/entities/appointment.dart';
import 'appointment_remote_datasource.dart';

class AppointmentRemoteDatasourceImpl implements AppointmentRemoteDatasource {
  final Dio client;

  AppointmentRemoteDatasourceImpl({required this.client});

  @override
  Future<Appointment> createAppointment({
    int? memberId,
    int? businessId,
    required int packageId,
    required int packagePriceId,
    required String clientFirstName,
    required String clientLastName,
    required DateTime appointmentDate,
    required double priceAtBooking,
    required double depositAmount,
    required double remainingAmount,
    required double commissionPercentAtBooking,
    required double commissionAmountAtBooking,
  }) async {
    final response = await client.post(
      '/appointments/',
      data: {
        if (memberId != null) 'member_id': memberId,
        if (businessId != null) 'business_id': businessId,
        'package_id': packageId,
        'package_price_id': packagePriceId,
        'client_first_name': clientFirstName,
        'client_last_name': clientLastName,
        'appointment_date': appointmentDate.toIso8601String(),
        'price_at_booking': priceAtBooking,
        'deposit_amount': depositAmount,
        'remaining_amount': remainingAmount,
        'commission_percent_at_booking': commissionPercentAtBooking,
        'commission_amount_at_booking': commissionAmountAtBooking,
      },
    );
    return AppointmentModel.fromJson(response.data);
  }

  @override
  Future<List<Appointment>> getMyAppointments({String? status}) async {
    final response = await client.get(
      '/appointments/me',
      queryParameters: {if (status != null) 'status': status},
    );
    final List<dynamic> list = response.data;
    return list.map((json) => AppointmentModel.fromJson(json)).toList();
  }

  @override
  Future<List<Appointment>> getAppointmentsForBusiness({
    required int businessId,
    String? status,
  }) async {
    final response = await client.get(
      '/appointments/business/$businessId',
      queryParameters: {if (status != null) 'status': status},
    );
    final List<dynamic> list = response.data;
    return list.map((json) => AppointmentModel.fromJson(json)).toList();
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
    String? appointmentLocation,
    String? appointmentDuration,
    String? appointmentNote,
    int? numberOfPersons,
    String? privacyOptOut,
    String? addsOns,
    int? memberId,
  }) async {
    final response = await client.patch(
      '/appointments/business/$businessId/appointments/$appointmentId',
      data: {
        if (clientName != null) 'client_name': clientName,
        if (clientEmail != null) 'client_email': clientEmail,
        if (clientPhone != null) 'client_phone': clientPhone,
        if (appointmentDate != null)
          'appointment_date': appointmentDate.toIso8601String(),
        if (appointmentLocation != null) 'appointment_location': appointmentLocation,
        if (appointmentDuration != null) 'appointment_duration': appointmentDuration,
        if (appointmentNote != null) 'appointment_note': appointmentNote,
        if (numberOfPersons != null) 'number_of_persons': numberOfPersons,
        if (privacyOptOut != null) 'privacy_opt_out': privacyOptOut,
        if (addsOns != null) 'adds_ons': addsOns,
        if (memberId != null) 'member_id': memberId,
      },
    );
    return AppointmentModel.fromJson(response.data);
  }

  @override
  Future<void> deleteAppointment(int appointmentId) async {
    await client.delete('/appointments/$appointmentId');
  }
}
