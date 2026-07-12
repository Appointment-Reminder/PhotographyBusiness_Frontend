import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/create_package.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/create_package_category.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_categories_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_packages_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_price_history.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/create_package_price.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';

import '../state/package_pricing_state.dart';

class PackagePricingNotifier extends StateNotifier<PackagePricingState> {
  final GetPackageCategoriesForBusiness getCategories;
  final GetPackagesForBusiness getPackages;
  final GetPackagePriceHistory getPriceHistory;
  final CreatePackagePrice createPrice;
  final CreatePackageCategory createCategory;
  final CreatePackage createPackage;

  PackagePricingNotifier({
    required this.getCategories,
    required this.getPackages,
    required this.getPriceHistory,
    required this.createPrice,
    required this.createCategory,
    required this.createPackage,
  }) : super(const PackagePricingState());

  Future<void> loadForBusiness(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);

    final catResult = await getCategories(GetPackageCategoriesForBusinessParams(businessId: businessId));
    final pkgResult = await getPackages(GetPackagesForBusinessParams(businessId: businessId));

    if (catResult.isLeft() || pkgResult.isLeft()) {
      state = state.copyWith(isLoading: false, error: 'Failed to load packages');
      return;
    }

    final categories = catResult.getOrElse(() => []);
    final packages = pkgResult.getOrElse(() => []);

    state = state.copyWith(categories: categories, packages: packages, isLoading: false);

    await Future.wait(packages.map((p) => _loadPricesFor(p.id)));
  }

  Future<void> _loadPricesFor(int packageId) async {
    final result = await getPriceHistory(GetPackagePriceHistoryParams(packageId: packageId));
    result.fold(
          (_) {}, // no prices yet — not an error
          (prices) => state = state.copyWith(priceHistory: {...state.priceHistory, packageId: prices}),
    );
  }

  Future<void> addCategory(int businessId, String name) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await createCategory(
      CreatePackageCategoryParams(businessId: businessId, name: name),
    );
    if (result.isLeft()) {
      state = state.copyWith(isSubmitting: false, error: result.fold((f) => f.message, (_) => null));
      return;
    }
    state = state.copyWith(isSubmitting: false);
    await loadForBusiness(businessId);
  }

  Future<void> addPackage({
    required int businessId,
    required int categoryId,
    required String name,
    required String description,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await createPackage(CreatePackageParams(
      name: name,
      description: description,
      businessId: businessId,
      categoryId: categoryId,
    ));
    if (result.isLeft()) {
      state = state.copyWith(isSubmitting: false, error: result.fold((f) => f.message, (_) => null));
      return;
    }
    state = state.copyWith(isSubmitting: false);
    await loadForBusiness(businessId);
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
    final result = await createPrice(CreatePackagePriceParams(
      packageId: packageId,
      totalPrice: totalPrice,
      depositAmount: depositAmount,
      remainingAmount: remainingAmount,
      isPersonal: isPersonal,
      effectiveFrom: effectiveFrom,
    ));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (_) {},
    );
    await _loadPricesFor(packageId);
    state = state.copyWith(isSubmitting: false);
  }

  void clear() => state = const PackagePricingState();
}