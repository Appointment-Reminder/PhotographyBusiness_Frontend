import 'package:equatable/equatable.dart';

class PackagePrice extends Equatable {
  final int id;
  final int packageId;
  final int totalPrice;
  final int depositAmount;
  final int remainingAmount;
  final bool isPersonal;
  final DateTime effectiveFrom;

  const PackagePrice({
    required this.id,
    required this.packageId,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
    required this.isPersonal,
    required this.effectiveFrom,
  });

  @override
  List<Object?> get props => [
        id,
        packageId,
        totalPrice,
        depositAmount,
        remainingAmount,
        isPersonal,
        effectiveFrom,
      ];
}
