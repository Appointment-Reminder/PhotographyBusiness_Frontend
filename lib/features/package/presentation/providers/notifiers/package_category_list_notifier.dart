// package_category_list_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/refacto/package_category_list_state.dart';
import '../../../domain/usecases/get_package_categories_for_business.dart';
import '../../../domain/usecases/package_params.dart';

class PackageCategoryListNotifier extends StateNotifier<PackageCategoryListState> {
  final GetPackageCategoriesForBusiness getCategories;

  PackageCategoryListNotifier({required this.getCategories}) : super(const PackageCategoryListState());

  Future<void> load(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getCategories(GetPackageCategoriesForBusinessParams(businessId: businessId));
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (categories) => state = state.copyWith(isLoading: false, categories: categories),
    );
  }
}