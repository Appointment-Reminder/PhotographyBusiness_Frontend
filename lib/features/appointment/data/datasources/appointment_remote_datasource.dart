import '../../domain/entities/appointment.dart';

abstract class AppointmentRemoteDatasource {
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
    String? clientFirstName,
    String? clientLastName,
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
  });

  Future<void> deleteAppointment(int appointmentId);
}
