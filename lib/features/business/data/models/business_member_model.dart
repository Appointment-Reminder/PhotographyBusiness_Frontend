
import '../../domain/entities/business_member.dart';

class BusinessMemberModel extends BusinessMember {
  const BusinessMemberModel({
    required super.id,
    required super.businessId,
    required super.userId,
    required super.role,
    required super.webhookToken,
    required super.invitedAt,
    required super.isActive,
    required super.createdAt,
    super.invitedBy,
    super.joinedAt,
    super.userEmail,
    super.userName,
  });

  factory BusinessMemberModel.fromJson(Map<String, dynamic> json){
    return BusinessMemberModel(
        id: json['id'],
        businessId: json['business_id'],
        userId: json['user']['id'],
        role: json['role'],
        webhookToken: json['webhook_token'],
        invitedAt: DateTime.parse(json['invited_at']),
        invitedBy: json['invited_by'],
        joinedAt: json['joined_at'] != null ? DateTime.parse(json['joined_at']) : null,
        isActive: json['is_active'],
        createdAt: DateTime.parse(json['created_at']),
        userName: json['user']['name'],
        userEmail: json['user']['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'user_id': userId,
      'role': role,
      'webhook_token': webhookToken,
      'invited_by': invitedBy,
      'invited_at': invitedAt.toIso8601String(),
      'joined_at': joinedAt?.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'user_name': userName,
      'user_email': userEmail,
    };
  }

}