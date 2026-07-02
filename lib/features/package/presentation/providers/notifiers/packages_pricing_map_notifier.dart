import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_price.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_categories_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_packages_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_price_history.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';

class PackagesPricingMapState {
  final List<PackageCategory> categories;
  final Map<int, List<Package>> packagesByCategory; // categoryId -> packages
  final Map<int, List<PackagePrice>> pricesByPackage; // packageId -> price history
  final bool isLoading;
  final String? error;

  const PackagesPricingMapState({
    this.categories = const [],
    this.packagesByCategory = const {},
    this.pricesByPackage = const {},
    this.isLoading = false,
    this.error,
  });

  PackagesPricingMapState copyWith({
    List<PackageCategory>? categories,
    Map<int, List<Package>>? packagesByCategory,
    Map<int, List<PackagePrice>>? pricesByPackage,
    bool? isLoading,
    String? error,
  }) {
    return PackagesPricingMapState(
      categories: categories ?? this.categories,
      packagesByCategory: packagesByCategory ?? this.packagesByCategory,
      pricesByPackage: pricesByPackage ?? this.pricesByPackage,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PackagesPricingMapNotifier extends StateNotifier<PackagesPricingMapState> {
  final GetPackageCategoriesForBusiness getCategories;
  final GetPackagesForBusiness getPackages;
  final GetPackagePriceHistory getPriceHistory;

  PackagesPricingMapNotifier({
    required this.getCategories,
    required this.getPackages,
    required this.getPriceHistory,
  }) : super(const PackagesPricingMapState());

  Future<void> loadForBusiness(int businessId) async {
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

  void clear() => state = const PackagesPricingMapState();
}