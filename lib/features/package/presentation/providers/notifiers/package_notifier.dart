import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/create_package.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/create_package_category.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/create_package_price.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/delete_package.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/delete_package_category.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_current_package_price.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_by_id.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_categories_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_price_history.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_packages_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/update_package.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/package_state.dart';

class PackageNotifier extends StateNotifier<PackageState> {
  final GetPackagesForBusiness getPackagesForBusiness;
  final GetPackageById getPackageById;
  final CreatePackage createPackage;
  final UpdatePackage updatePackage;
  final DeletePackage deletePackage;
  final GetPackageCategoriesForBusiness getPackageCategoriesForBusiness;
  final CreatePackageCategory createPackageCategory;
  final DeletePackageCategory deletePackageCategory;
  final CreatePackagePrice createPackagePrice;
  final GetPackagePriceHistory getPackagePriceHistory;
  final GetCurrentPackagePrice getCurrentPackagePrice;

  PackageNotifier({
    required this.getPackagesForBusiness,
    required this.getPackageById,
    required this.createPackage,
    required this.updatePackage,
    required this.deletePackage,
    required this.getPackageCategoriesForBusiness,
    required this.createPackageCategory,
    required this.deletePackageCategory,
    required this.createPackagePrice,
    required this.getPackagePriceHistory,
    required this.getCurrentPackagePrice,
  }) : super(const PackageInitial());

  Future<void> loadPackagesForBusiness(int businessId) async {
    state = const PackageLoading();

    final result = await getPackagesForBusiness(
      GetPackagesForBusinessParams(businessId: businessId),
    );

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (packages) => state = PackageListLoaded(packages: packages),
    );
  }

  Future<void> loadPackageById(int packageId) async {
    state = const PackageLoading();

    final packageResult = await getPackageById(GetPackageByIdParams(packageId: packageId));

    await packageResult.fold(
      (failure) async {
        state = PackageError(message: failure.message);
      },
      (package) async {
        final priceResult = await getCurrentPackagePrice(
          GetCurrentPackagePriceParams(packageId: packageId),
        );

        priceResult.fold(
          (_) => state = PackageDetailLoaded(package: package),
          (currentPrice) => state = PackageDetailLoaded(
            package: package,
            currentPrice: currentPrice,
          ),
        );
      },
    );
  }

  Future<void> createNewPackage({
    required String name,
    required String description,
    required int businessId,
    required int categoryId,
  }) async {
    state = const PackageLoading();

    final result = await createPackage(
      CreatePackageParams(
        name: name,
        description: description,
        businessId: businessId,
        categoryId: categoryId,
      ),
    );

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (package) => state = PackageDetailLoaded(package: package),
    );
  }

  Future<void> updateExistingPackage({
    required int id,
    required int businessId,
    required int categoryId,
    required String name,
    required String description,
  }) async {
    state = const PackageLoading();

    final result = await updatePackage(
      UpdatePackageParams(
        id: id,
        businessId: businessId,
        categoryId: categoryId,
        name: name,
        description: description,
      ),
    );

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (package) => state = PackageDetailLoaded(package: package),
    );
  }

  Future<void> deletePackageById(int packageId) async {
    state = const PackageLoading();

    final result = await deletePackage(DeletePackageParams(packageId: packageId));

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (_) => state = const PackageInitial(),
    );
  }

  Future<void> loadCategoriesForBusiness(int businessId) async {
    state = const PackageLoading();

    final result = await getPackageCategoriesForBusiness(
      GetPackageCategoriesForBusinessParams(businessId: businessId),
    );

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (categories) => state = PackageCategoryListLoaded(categories: categories),
    );
  }

  Future<void> createNewCategory({
    required int businessId,
    required String name,
  }) async {
    state = const PackageLoading();

    final result = await createPackageCategory(
      CreatePackageCategoryParams(businessId: businessId, name: name),
    );

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (_) => loadCategoriesForBusiness(businessId),
    );
  }

  Future<void> deleteCategoryById({
    required int categoryId,
    required int businessId,
  }) async {
    state = const PackageLoading();

    final result = await deletePackageCategory(
      DeletePackageCategoryParams(categoryId: categoryId),
    );

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (_) => loadCategoriesForBusiness(businessId),
    );
  }

  Future<void> createNewPrice({
    required int packageId,
    required int totalPrice,
    required int depositAmount,
    required int remainingAmount,
    required bool isPersonal,
    required DateTime effectiveFrom,
  }) async {
    state = const PackageLoading();

    final result = await createPackagePrice(
      CreatePackagePriceParams(
        packageId: packageId,
        totalPrice: totalPrice,
        depositAmount: depositAmount,
        remainingAmount: remainingAmount,
        isPersonal: isPersonal,
        effectiveFrom: effectiveFrom,
      ),
    );

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (_) => loadPackageById(packageId),
    );
  }

  Future<void> loadPriceHistory(int packageId) async {
    state = const PackageLoading();

    final result = await getPackagePriceHistory(
      GetPackagePriceHistoryParams(packageId: packageId),
    );

    result.fold(
      (failure) => state = PackageError(message: failure.message),
      (prices) => state = PackagePriceHistoryLoaded(prices: prices),
    );
  }
}
