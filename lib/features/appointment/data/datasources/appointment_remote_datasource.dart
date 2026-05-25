import '../../domain/entities/appointment.dart';

abstract class AppointmentRemoteDatasource {
  Future<Appointment> createAppointment({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    required DateTime appointmentDate,
    required int userId,
    required int businessId,
  });

  Future<List<Appointment>> getMyAppointments({String? status});

  Future<List<Appointment>> getAppointmentsForBusiness({
    required int businessId,
    String? status,
  });

  Future<Appointment> getAppointmentById({
    required int businessId,
    required int appointmentId,
  });

  Future<Appointment> updateAppointment({
    required int businessId,
    required int appointmentId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    int? userId,
  });

  Future<void> deleteAppointment(int appointmentId);
}