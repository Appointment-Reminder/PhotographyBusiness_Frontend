
import 'package:equatable/equatable.dart';

class MemberCommission extends Equatable {
  final int id;
  final int businessMemberId;
  final int packageId;
  final int commissionPercent;
  final DateTime effectivefrom;

  const MemberCommission({
    required this.id,
    required this.businessMemberId,
    required this.packageId,
    required this.commissionPercent,
    required this.effectivefrom
  });



  @override
  List<Object?> get props => [id, businessMemberId, packageId, commissionPercent, effectivefrom];
}