import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/package/data/datasources/package_remote_datasource.dart';
import 'package:photography_business_frontend/features/package/data/datasources/package_remote_datasource_impl.dart';
import 'package:photography_business_frontend/features/package/data/repositories/package_repository_impl.dart';
import 'package:photography_business_frontend/features/package/domain/repositories/package_repository.dart';
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
import 'package:photography_business_frontend/features/package/domain/usecases/update_package.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/notifiers/package_notifier.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/notifiers/packages_pricing_map_notifier.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/package_state.dart';

final packageRemoteDataSourceProvider = Provider<PackageRemoteDatasource>((ref) {
  return PackageRemoteDatasourceImpl(client: ref.read(dioProvider));
});

final packageRepositoryProvider = Provider<PackageRepository>((ref) {
  return PackageRepositoryImpl(
    remoteDatasource: ref.read(packageRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final getPackagesForBusinessProvider = Provider<GetPackagesForBusiness>((ref) {
  return GetPackagesForBusiness(repository: ref.read(packageRepositoryProvider));
});

final getPackageByIdProvider = Provider<GetPackageById>((ref) {
  return GetPackageById(repository: ref.read(packageRepositoryProvider));
});

final createPackageProvider = Provider<CreatePackage>((ref) {
  return CreatePackage(repository: ref.read(packageRepositoryProvider));
});

final updatePackageProvider = Provider<UpdatePackage>((ref) {
  return UpdatePackage(repository: ref.read(packageRepositoryProvider));
});

final deletePackageProvider = Provider<DeletePackage>((ref) {
  return DeletePackage(repository: ref.read(packageRepositoryProvider));
});

final getPackageCategoriesForBusinessProvider = Provider<GetPackageCategoriesForBusiness>((ref) {
  return GetPackageCategoriesForBusiness(repository: ref.read(packageRepositoryProvider));
});

final createPackageCategoryProvider = Provider<CreatePackageCategory>((ref) {
  return CreatePackageCategory(repository: ref.read(packageRepositoryProvider));
});

final deletePackageCategoryProvider = Provider<DeletePackageCategory>((ref) {
  return DeletePackageCategory(repository: ref.read(packageRepositoryProvider));
});

final createPackagePriceProvider = Provider<CreatePackagePrice>((ref) {
  return CreatePackagePrice(repository: ref.read(packageRepositoryProvider));
});

final getPackagePriceHistoryProvider = Provider<GetPackagePriceHistory>((ref) {
  return GetPackagePriceHistory(repository: ref.read(packageRepositoryProvider));
});

final getCurrentPackagePriceProvider = Provider<GetCurrentPackagePrice>((ref) {
  return GetCurrentPackagePrice(repository: ref.read(packageRepositoryProvider));
});

final packageNotifierProvider = StateNotifierProvider<PackageNotifier, PackageState>((ref) {
  return PackageNotifier(
    getPackagesForBusiness: ref.read(getPackagesForBusinessProvider),
    getPackageById: ref.read(getPackageByIdProvider),
    createPackage: ref.read(createPackageProvider),
    updatePackage: ref.read(updatePackageProvider),
    deletePackage: ref.read(deletePackageProvider),
    getPackageCategoriesForBusiness: ref.read(getPackageCategoriesForBusinessProvider),
    createPackageCategory: ref.read(createPackageCategoryProvider),
    deletePackageCategory: ref.read(deletePackageCategoryProvider),
    createPackagePrice: ref.read(createPackagePriceProvider),
    getPackagePriceHistory: ref.read(getPackagePriceHistoryProvider),
    getCurrentPackagePrice: ref.read(getCurrentPackagePriceProvider),
  );
});

final packagesPricingMapProvider =
StateNotifierProvider<PackagesPricingMapNotifier, PackagesPricingMapState>((ref) {
  return PackagesPricingMapNotifier(
    getCategories: ref.read(getPackageCategoriesForBusinessProvider),
    getPackages: ref.read(getPackagesForBusinessProvider),
    getPriceHistory: ref.read(getPackagePriceHistoryProvider),
  );
});