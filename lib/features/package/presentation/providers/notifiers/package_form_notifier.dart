// package_form_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/refacto/package_form_state.dart';
import '../../../domain/usecases/create_package.dart';
import '../../../domain/usecases/update_package.dart';
import '../../../domain/usecases/delete_package.dart';
import '../../../domain/usecases/package_params.dart';

class PackageFormNotifier extends StateNotifier<PackageFormState> {
  final CreatePackage createPackage;
  final UpdatePackage updatePackage;
  final DeletePackage deletePackage;

  PackageFormNotifier({
    required this.createPackage,
    required this.updatePackage,
    required this.deletePackage,
  }) : super(const PackageFormState());

  Future<void> create({
    required String name,
    required String description,
    required int businessId,
    required int categoryId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await createPackage(CreatePackageParams(
      name: name, description: description, businessId: businessId, categoryId: categoryId,
    ));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (p) => state = state.copyWith(isSubmitting: false, saved: p),
    );
  }

  Future<void> update({
    required int id,
    required int businessId,
    required int categoryId,
    required String name,
    required String description,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await updatePackage(UpdatePackageParams(
      id: id, businessId: businessId, categoryId: categoryId, name: name, description: description,
    ));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (p) => state = state.copyWith(isSubmitting: false, saved: p),
    );
  }

  Future<bool> delete(int packageId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await deletePackage(DeletePackageParams(packageId: packageId));
    return result.fold(
          (f) {
        state = state.copyWith(isSubmitting: false, error: f.message);
        return false;
      },
          (_) {
        state = state.copyWith(isSubmitting: false);
        return true;
      },
    );
  }
}