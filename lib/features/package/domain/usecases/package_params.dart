import 'package:equatable/equatable.dart';

class CreatePackageParams extends Equatable {
  final String name;
  final String description;
  final int businessId;
  final int categoryId;

  const CreatePackageParams({
    required this.name,
    required this.description,
    required this.businessId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [name, description, businessId, categoryId];
}

class UpdatePackageParams extends Equatable {
  final int id;
  final int businessId;
  final int categoryId;
  final String name;
  final String description;

  const UpdatePackageParams({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [id, businessId, categoryId, name, description];
}

class GetPackagesForBusinessParams extends Equatable {
  final int businessId;

  const GetPackagesForBusinessParams({required this.businessId});

  @override
  List<Object?> get props => [businessId];
}

class GetPackageByIdParams extends Equatable {
  final int packageId;

  const GetPackageByIdParams({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}

class DeletePackageParams extends Equatable {
  final int packageId;

  const DeletePackageParams({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}

class CreatePackageCategoryParams extends Equatable {
  final int businessId;
  final String name;

  const CreatePackageCategoryParams({
    required this.businessId,
    required this.name,
  });

  @override
  List<Object?> get props => [businessId, name];
}

class GetPackageCategoriesForBusinessParams extends Equatable {
  final int businessId;

  const GetPackageCategoriesForBusinessParams({required this.businessId});

  @override
  List<Object?> get props => [businessId];
}

class DeletePackageCategoryParams extends Equatable {
  final int categoryId;

  const DeletePackageCategoryParams({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class CreatePackagePriceParams extends Equatable {
  final int packageId;
  final int totalPrice;
  final int depositAmount;
  final int remainingAmount;
  final bool isPersonal;
  final DateTime effectiveFrom;

  const CreatePackagePriceParams({
    required this.packageId,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
    required this.isPersonal,
    required this.effectiveFrom,
  });

  @override
  List<Object?> get props => [
        packageId,
        totalPrice,
        depositAmount,
        remainingAmount,
        isPersonal,
        effectiveFrom,
      ];
}

class GetPackagePriceHistoryParams extends Equatable {
  final int packageId;

  const GetPackagePriceHistoryParams({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}

class GetCurrentPackagePriceParams extends Equatable {
  final int packageId;

  const GetCurrentPackagePriceParams({required this.packageId});

  @override
  List<Object?> get props => [packageId];
}
