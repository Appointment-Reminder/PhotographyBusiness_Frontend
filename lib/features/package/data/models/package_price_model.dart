import '../../domain/entities/package_price.dart';

class PackagePriceModel extends PackagePrice {
  const PackagePriceModel({
    required super.id,
    required super.packageId,
    required super.totalPrice,
    required super.depositAmount,
    required super.remainingAmount,
    required super.isPersonal,
    required super.effectiveFrom,
  });

  factory PackagePriceModel.fromJson(Map<String, dynamic> json) {
    return PackagePriceModel(
      id: json['id'],
      packageId: json['package_id'],
      totalPrice: json['total_price'],
      depositAmount: json['deposit_amount'],
      remainingAmount: json['remaining_amount'],
      isPersonal: json['is_personal'],
      effectiveFrom: DateTime.parse(json['effective_from']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
      'total_price': totalPrice,
      'deposit_amount': depositAmount,
      'remaining_amount': remainingAmount,
      'is_personal': isPersonal,
      'effective_from': effectiveFrom.toIso8601String(),
    };
  }
}
