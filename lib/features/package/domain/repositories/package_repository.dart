import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/package.dart';
import '../entities/package_category.dart';
import '../entities/package_price.dart';

abstract class PackageRepository {
  Future<Either<Failure, Package>> createPackage({
    required String name,
    required String description,
    required int businessId,
    required int categoryId,
  });

  Future<Either<Failure, Package>> updatePackage({
    required int id,
    required int businessId,
    required int categoryId,
    required String name,
    required String description,
  });

  Future<Either<Failure, List<Package>>> getPackagesForBusiness(int businessId);

  Future<Either<Failure, Package>> getPackageById(int packageId);

  Future<Either<Failure, void>> deletePackage(int packageId);

  Future<Either<Failure, PackageCategory>> createPackageCategory({
    required int businessId,
    required String name,
  });

  Future<Either<Failure, List<PackageCategory>>> getPackageCategoriesForBusiness(int businessId);

  Future<Either<Failure, void>> deletePackageCategory(int categoryId);

  Future<Either<Failure, PackagePrice>> createPackagePrice({
    required int packageId,
    required int totalPrice,
    required int depositAmount,
    required int remainingAmount,
    required bool isPersonal,
    required DateTime effectiveFrom,
  });

  Future<Either<Failure, List<PackagePrice>>> getPackagePriceHistory(int packageId);

  Future<Either<Failure, PackagePrice>> getCurrentPackagePrice(int packageId);
}
