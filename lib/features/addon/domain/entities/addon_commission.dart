import 'package:equatable/equatable.dart';

/// A Business Member's commission on an Add-on. The backend answers a flat 0
/// when the Member has none, so there is always a value to show.
class AddonCommission extends Equatable {
  final int? id;
  final int businessMemberId;
  final int addonId;
  final int commissionAmount;
  final bool commissionIsPercentage;
  final DateTime effectiveFrom;

  const AddonCommission({
    this.id,
    required this.businessMemberId,
    required this.addonId,
    required this.commissionAmount,
    required this.commissionIsPercentage,
    required this.effectiveFrom,
  });

  @override
  List<Object?> get props =>
      [id, businessMemberId, addonId, commissionAmount, commissionIsPercentage, effectiveFrom];
}
