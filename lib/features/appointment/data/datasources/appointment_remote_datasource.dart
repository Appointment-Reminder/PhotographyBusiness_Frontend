import '../../domain/entities/appointment.dart';
import '../../domain/workflow/appointment_event.dart';

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

  Future<Appointment> addAppointmentAddon({
    required int businessId,
    required int appointmentId,
    required int addonId,
    required int quantity,
  });

  Future<Appointment> changeAppointmentAddonQuantity({
    required int businessId,
    required int appointmentId,
    required int addonId,
    required int quantity,
  });

  Future<Appointment> removeAppointmentAddon({
    required int businessId,
    required int appointmentId,
    required int addonId,
  });

  Future<Appointment> resolveUnresolvedAddon({
    required int businessId,
    required int appointmentId,
    required int unresolvedId,
    required int addonId,
    required int quantity,
  });

  /// Fires an Appointment Event; returns the Appointment with its new status.
  Future<Appointment> fireAppointmentEvent({
    required int businessId,
    required int appointmentId,
    required AppointmentEvent event,
  });
}
