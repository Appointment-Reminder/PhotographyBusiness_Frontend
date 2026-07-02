import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_price.dart';

class PackagePricingState {
  final List<PackageCategory> categories;
  final List<Package> packages;
  // packageId -> price history, sorted by effectiveFrom
  final Map<int, List<PackagePrice>> priceHistory;
  final bool isLoading;
  final String? error;

  const PackagePricingState({
    this.categories = const [],
    this.packages = const [],
    this.priceHistory = const {},
    this.isLoading = false,
    this.error,
  });

  List<Package> packagesFor(int categoryId) =>
      packages.where((p) => p.categoryId == categoryId).toList();

  List<PackagePrice> pricesFor(int packageId) => priceHistory[packageId] ?? const [];

  PackagePrice? currentPriceFor(int packageId) {
    final list = pricesFor(packageId);
    if (list.isEmpty) return null;
    return list.reduce((a, b) => a.effectiveFrom.isAfter(b.effectiveFrom) ? a : b);
  }

  PackagePricingState copyWith({
    List<PackageCategory>? categories,
    List<Package>? packages,
    Map<int, List<PackagePrice>>? priceHistory,
    bool? isLoading,
    String? error,
  }) {
    return PackagePricingState(
      categories: categories ?? this.categories,
      packages: packages ?? this.packages,
      priceHistory: priceHistory ?? this.priceHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}