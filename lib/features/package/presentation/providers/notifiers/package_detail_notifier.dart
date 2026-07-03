// package_detail_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/refacto/package_detail_state.dart';
import '../../../domain/usecases/get_package_by_id.dart';
import '../../../domain/usecases/get_current_package_price.dart';
import '../../../domain/usecases/package_params.dart';

class PackageDetailNotifier extends StateNotifier<PackageDetailState> {
  final GetPackageById getPackageById;
  final GetCurrentPackagePrice getCurrentPackagePrice;

  PackageDetailNotifier({required this.getPackageById, required this.getCurrentPackagePrice})
      : super(const PackageDetailState());

  Future<void> load(int packageId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getPackageById(GetPackageByIdParams(packageId: packageId));

    await result.fold(
          (f) async => state = state.copyWith(isLoading: false, error: f.message),
          (package) async {
        final priceResult = await getCurrentPackagePrice(GetCurrentPackagePriceParams(packageId: packageId));
        priceResult.fold(
              (_) => state = state.copyWith(isLoading: false, package: package),
              (price) => state = state.copyWith(isLoading: false, package: package, currentPrice: price),
        );
      },
    );
  }

  void clear() => state = const PackageDetailState();
}