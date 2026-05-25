import 'package:equatable/equatable.dart';

class Appointment extends Equatable {
  final int id;
  final String clientName;
  final String clientEmail;
  final String? clientPhone;
  final DateTime appointmentDate;
  final int userId;
  final int businessId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int photographerId;
  final String photographerName;
  final String photographerEmail;

  const Appointment({
    required this.id,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.appointmentDate,
    required this.userId,
    required this.businessId,
    required this.createdAt,
    required this.updatedAt,
    required this.photographerId,
    required this.photographerName,
    required this.photographerEmail});






  @override
  List<Object?> get props => [
    id,
    clientName,
    clientEmail,
    clientPhone,
    appointmentDate,
    userId,
    businessId,
    createdAt,
    updatedAt,
    photographerId,
    photographerName,
    photographerEmail,
  ];
}