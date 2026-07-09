
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';

class MemberCommissionModel extends MemberCommission {
  const MemberCommissionModel({
    required super.id,
    required super.businessMemberId,
    required super.packageId,
    required super.effectivefrom,
    required super.commissionAmount, required super.commissionIsPercentage});
  
  factory MemberCommissionModel.fromJson(Map<String, dynamic> json){
    return MemberCommissionModel(
      id: json['id'],
      businessMemberId: json['business_member_id'],
      packageId: json['package_id'],
      effectivefrom: DateTime.parse(json['effective_from']),
      commissionAmount: json['commission_amount'],
       commissionIsPercentage: json['commission_isPercentage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_member_id': businessMemberId,
      'package_id': packageId,
      'commission_amount': commissionAmount,
      'commission_isPercentage': commissionIsPercentage,
      'effective_from': effectivefrom.toIso8601String(),
    };
  }
}