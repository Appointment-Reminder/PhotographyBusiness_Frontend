// package_category_form_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/refacto/package_category_form_state.dart';
import '../../../domain/usecases/create_package_category.dart';
import '../../../domain/usecases/delete_package_category.dart';
import '../../../domain/usecases/package_params.dart';
import 'package_category_list_notifier.dart';

class PackageCategoryFormNotifier extends StateNotifier<PackageCategoryFormState> {
  final CreatePackageCategory createCategory;
  final DeletePackageCategory deleteCategory;
  final PackageCategoryListNotifier listNotifier;

  PackageCategoryFormNotifier({
    required this.createCategory,
    required this.deleteCategory,
    required this.listNotifier,
  }) : super(const PackageCategoryFormState());

  Future<void> create(int businessId, String name) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await createCategory(CreatePackageCategoryParams(businessId: businessId, name: name));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (c) => state = state.copyWith(isSubmitting: false, saved: c),
    );
    await listNotifier.load(businessId);
  }

  Future<void> delete(int businessId, int categoryId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await deleteCategory(DeletePackageCategoryParams(categoryId: categoryId));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (_) => state = state.copyWith(isSubmitting: false),
    );
    await listNotifier.load(businessId);
  }
}