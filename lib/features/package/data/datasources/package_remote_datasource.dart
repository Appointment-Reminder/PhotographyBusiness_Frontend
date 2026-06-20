import '../../domain/entities/package.dart';
import '../../domain/entities/package_category.dart';
import '../../domain/entities/package_price.dart';

abstract class PackageRemoteDatasource {
  // Packages
  Future<Package> createPackage({
    required String name,
    required String description,
    required int businessId,
    required int categoryId,
  });

  Future<Package> updatePackage({
    required int id,
    required int businessId,
    required int categoryId,
    required String name,
    required String description,
  });

  Future<List<Package>> getPackagesForBusiness(int businessId);

  Future<Package> getPackageById(int packageId);

  Future<void> deletePackage(int packageId);

  // Categories
  Future<PackageCategory> createPackageCategory({
    required int businessId,
    required String name,
  });

  Future<List<PackageCategory>> getPackageCategoriesForBusiness(int businessId);

  Future<void> deletePackageCategory(int categoryId);

  // Prices
  Future<PackagePrice> createPackagePrice({
    required int packageId,
    required int totalPrice,
    required int depositAmount,
    required int remainingAmount,
    required bool isPersonal,
    required DateTime effectiveFrom,
  });

  Future<List<PackagePrice>> getPackagePriceHistory(int packageId);

  Future<PackagePrice> getCurrentPackagePrice(int packageId);
}
