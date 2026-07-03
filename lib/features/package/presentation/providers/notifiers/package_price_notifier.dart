// package_price_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/refacto/package_price_state.dart';
import '../../../domain/usecases/get_package_price_history.dart';
import '../../../domain/usecases/create_package_price.dart';
import '../../../domain/usecases/package_params.dart';

class PackagePriceNotifier extends StateNotifier<PackagePriceState> {
  final GetPackagePriceHistory getPriceHistory;
  final CreatePackagePrice createPrice;

  PackagePriceNotifier({required this.getPriceHistory, required this.createPrice})
      : super(const PackagePriceState());

  Future<void> loadHistory(int packageId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getPriceHistory(GetPackagePriceHistoryParams(packageId: packageId));
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (prices) => state = state.copyWith(isLoading: false, history: prices),
    );
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
          (price) => state = state.copyWith(isSubmitting: false, current: price),
    );
    await loadHistory(packageId);
  }
}