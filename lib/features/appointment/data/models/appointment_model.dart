import '../../domain/entities/appointment.dart';

class AppointmentModel extends Appointment {
  const AppointmentModel({
    required super.id,
    required super.clientName,
    required super.clientEmail,
    super.clientPhone,
    required super.appointmentDate,
    required super.userId,
    required super.businessId,
    required super.createdAt,
    required super.updatedAt,
    required super.photographerId,
    required super.photographerName,
    required super.photographerEmail
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'],
      clientName: json['client_name'],
      clientEmail: json['client_email'],
      clientPhone: json['client_phone'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      userId: json['user_id'],
      businessId: json['business_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      photographerId: json['user']['id'],
      photographerName: json['user']['name'],
      photographerEmail: json['user']['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_name': clientName,
      'client_email': clientEmail,
      'client_phone': clientPhone,
      'appointment_date': appointmentDate.toIso8601String(),
      'user_id': userId,
      'business_id': businessId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user': {
        'id': photographerId,
        'name': photographerName,
        'email': photographerEmail,
      },
    };
  }
}