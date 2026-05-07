import 'package:equatable/equatable.dart';

class BusinessMember extends Equatable {
  final int id;
  final int businessId;
  final int userId;
  final String role;
  final String webhookToken;
  final int? invitedBy;
  final DateTime invitedAt;
  final DateTime? joinedAt;
  final bool isActive;
  final DateTime createdAt;

  // Populated fields from user join
  final String? userName;
  final String? userEmail;

  const BusinessMember({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.role,
    required this.webhookToken,
    this.invitedBy,
    required this.invitedAt,
    this.joinedAt,
    required this.isActive,
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  @override
  List<Object?> get props => [
    id,
    businessId,
    userId,
    role,
    webhookToken,
    invitedBy,
    invitedAt,
    joinedAt,
    isActive,
    createdAt,
    userName,
    userEmail,
  ];
}