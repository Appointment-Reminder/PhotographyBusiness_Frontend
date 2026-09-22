import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_price.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_categories_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_packages_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_price_history.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';

import '../../../domain/usecases/create_package.dart';
import '../../../domain/usecases/create_package_category.dart';
import '../../../domain/usecases/create_package_price.dart';
import '../../../domain/usecases/delete_package.dart';
import '../../../domain/usecases/update_package.dart';

class PackagesPricingMapState {
  final List<PackageCategory> categories;
  final Map<int, List<Package>> packagesByCategory; // categoryId -> packages
  final Map<int, List<PackagePrice>> pricesByPackage; // packageId -> price history
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const PackagesPricingMapState({
    this.categories = const [],
    this.packagesByCategory = const {},
    this.pricesByPackage = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  PackagesPricingMapState copyWith({
    List<PackageCategory>? categories,
    Map<int, List<Package>>? packagesByCategory,
    Map<int, List<PackagePrice>>? pricesByPackage,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) {
    return PackagesPricingMapState(
      categories: categories ?? this.categories,
      packagesByCategory: packagesByCategory ?? this.packagesByCategory,
      pricesByPackage: pricesByPackage ?? this.pricesByPackage,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }
}

class PackagesPricingMapNotifier extends StateNotifier<PackagesPricingMapState> {
  final GetPackageCategoriesForBusiness getCategories;
  final GetPackagesForBusiness getPackages;
  final GetPackagePriceHistory getPriceHistory;

  final CreatePackageCategory createCategory;
  final CreatePackage createPackage;
  final UpdatePackage updatePackage;
  final DeletePackage deletePackage;
  final CreatePackagePrice createPrice;

  int? _businessId;

  PackagesPricingMapNotifier({
    required this.getCategories,
    required this.getPackages,
    required this.getPriceHistory,
    required this.createCategory,
    required this.createPackage,
    required this.updatePackage,
    required this.deletePackage,
    required this.createPrice,
  }) : super(const PackagesPricingMapState());

  Future<void> loadForBusiness(int businessId) async {
    _businessId = businessId;
    state = state.copyWith(isLoading: true, error: null);

    final catsResult = await getCategories(
      GetPackageCategoriesForBusinessParams(businessId: businessId),
    );
    final pkgsResult = await getPackages(
      GetPackagesForBusinessParams(businessId: businessId),
    );

    if (catsResult.isLeft() || pkgsResult.isLeft()) {
      final message = catsResult.fold((f) => f.message, (_) => null) ??
          pkgsResult.fold((f) => f.message, (_) => null) ??
          'Failed to load packages';
      state = state.copyWith(isLoading: false, error: message);
      return;
    }

    final categories = catsResult.getOrElse(() => []);
    final packages = pkgsResult.getOrElse(() => []);

    final grouped = <int, List<Package>>{};
    for (final p in packages) {
      grouped.putIfAbsent(p.categoryId, () => []).add(p);
    }

    state = state.copyWith(
      categories: categories,
      packagesByCategory: grouped,
      isLoading: false,
    );

    // fetch price history for every package in parallel
    await Future.wait(packages.map((p) => loadPriceHistory(p.id)));
  }

  Future<void> addCategory(String name) async {
    if (_businessId == null) return;
    state = state.copyWith(isSubmitting: true, error: null);
    await createCategory(CreatePackageCategoryParams(businessId: _businessId!, name: name));
    await loadForBusiness(_businessId!); // this already resets isLoading; isSubmitting stays true until we clear it
    state = state.copyWith(isSubmitting: false);
  }

  Future<void> addPackage({required int categoryId, required String name, required String description}) async {
    if (_businessId == null) return;
    state = state.copyWith(isSubmitting: true, error: null);
    await createPackage(CreatePackageParams(
      name: name, description: description, businessId: _businessId!, categoryId: categoryId,
    ));
    await loadForBusiness(_businessId!);
    state = state.copyWith(isSubmitting: false);
  }

  Future<void> editPackage({
    required int id,
    required int categoryId,
    required String name,
    required String description,
    String? jotformAlias,
  }) async {
    if (_businessId == null) return;
    state = state.copyWith(isSubmitting: true, error: null);
    await updatePackage(UpdatePackageParams(
      id: id,
      name: name, description: description, jotformAlias: jotformAlias,
    ));
    await loadForBusiness(_businessId!);
    state = state.copyWith(isSubmitting: false);
  }

  Future<void> removePackage(int packageId) async {
    if (_businessId == null) return;
    state = state.copyWith(isSubmitting: true, error: null);
    await deletePackage(DeletePackageParams(packageId: packageId));
    await loadForBusiness(_businessId!);
    state = state.copyWith(isSubmitting: false);
  }

  Future<void> addPrice({
    required int packageId,
    required int totalPrice,
    required int depositAmount,
    required int remainingAmount,
    required bool isPersonal,
    required DateTime effectiveFrom,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    await createPrice(CreatePackagePriceParams(
      packageId: packageId, totalPrice: totalPrice, depositAmount: depositAmount,
      remainingAmount: remainingAmount, isPersonal: isPersonal, effectiveFrom: effectiveFrom,
    ));
    await loadPriceHistory(packageId);
    state = state.copyWith(isSubmitting: false);
  }

  void clear() => state = const PackagesPricingMapState();

  Future<void> loadPriceHistory(int packageId) async {
    final result = await getPriceHistory(
      GetPackagePriceHistoryParams(packageId: packageId),
    );

    result.fold(
          (_) {}, // leave stale/empty on failure, don't blow up the whole tree
          (prices) {
        state = state.copyWith(
          pricesByPackage: {...state.pricesByPackage, packageId: prices},
        );
      },
    );
  }
}