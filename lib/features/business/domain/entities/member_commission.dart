
import 'package:equatable/equatable.dart';

class MemberCommission extends Equatable {
  final int id;
  final int businessMemberId;
  final int packageId;
  final int commissionAmount;
  final bool commissionIsPercentage;
  final DateTime effectivefrom;

  const MemberCommission({
    required this.id,
    required this.businessMemberId,
    required this.packageId,
    required this.commissionAmount,
    required this.effectivefrom,
    required this.commissionIsPercentage
  });



  @override
  List<Object?> get props => [id, businessMemberId, packageId, commissionAmount, commissionIsPercentage, effectivefrom];
}