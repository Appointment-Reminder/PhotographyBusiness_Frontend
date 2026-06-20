import '../../domain/entities/package_category.dart';

class PackageCategoryModel extends PackageCategory {
  const PackageCategoryModel({
    required super.id,
    required super.name,
    required super.businessId,
  });

  factory PackageCategoryModel.fromJson(Map<String, dynamic> json) {
    return PackageCategoryModel(
      id: json['id'],
      name: json['name'],
      businessId: json['business_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'business_id': businessId,
    };
  }
}
