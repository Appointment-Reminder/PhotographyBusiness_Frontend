// package_list_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/refacto/package_list_state.dart';
import '../../../domain/usecases/get_packages_for_business.dart';
import '../../../domain/usecases/package_params.dart';


class PackageListNotifier extends StateNotifier<PackageListState> {
  final GetPackagesForBusiness getPackagesForBusiness;

  PackageListNotifier({required this.getPackagesForBusiness}) : super(const PackageListState());

  Future<void> load(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getPackagesForBusiness(GetPackagesForBusinessParams(businessId: businessId));
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (packages) => state = state.copyWith(isLoading: false, packages: packages),
    );
  }
}