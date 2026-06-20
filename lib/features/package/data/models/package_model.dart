import '../../domain/entities/package.dart';

class PackageModel extends Package {
  const PackageModel({
    required super.id,
    required super.businessId,
    required super.categoryId,
    required super.name,
    required super.description,
    required super.isActive,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) {
    return PackageModel(
      id: json['id'],
      businessId: json['business_id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'is_active': isActive,
    };
  }
}
