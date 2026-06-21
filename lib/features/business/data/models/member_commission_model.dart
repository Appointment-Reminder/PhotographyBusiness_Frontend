
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';

class MemberCommissionModel extends MemberCommission {
  const MemberCommissionModel({required super.id, required super.businessMemberId, required super.packageId, required super.commissionPercent, required super.effectivefrom});
  
  factory MemberCommissionModel.fromJson(Map<String, dynamic> json){
    return MemberCommissionModel(
      id: json['id'],
      businessMemberId: json['business_member_id'],
      packageId: json['package_id'],
      commissionPercent: json['commission_percent'],
      effectivefrom: DateTime.parse(json['effective_from']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_member_id': businessMemberId,
      'package_id': packageId,
      'commission_percent': commissionPercent,
      'effective_from': effectivefrom.toIso8601String(),
    };
  }
}