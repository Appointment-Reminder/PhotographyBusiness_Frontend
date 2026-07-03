// business_form_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/Refacto/Business_form_state.dart';
import '../../../domain/usecases/create_business.dart';
import '../../../domain/usecases/update_business.dart';
import '../../../domain/usecases/delete_business.dart';
import '../../../domain/usecases/business_params.dart';

class BusinessFormNotifier extends StateNotifier<BusinessFormState> {
  final CreateBusinessUser createBusiness;
  final UpdateBusinessUser updateBusiness;
  final DeleteBusinessUser deleteBusiness;

  BusinessFormNotifier({
    required this.createBusiness,
    required this.updateBusiness,
    required this.deleteBusiness,
  }) : super(const BusinessFormState());

  Future<void> create(String name, String? description) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await createBusiness(CreateBusinessParams(name: name, description: description));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (b) => state = state.copyWith(isSubmitting: false, saved: b),
    );
  }

  Future<void> update(int businessId, String? name, String? description) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await updateBusiness(
      UpdateBusinessParams(businessId: businessId, name: name, description: description),
    );
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (b) => state = state.copyWith(isSubmitting: false, saved: b),
    );
  }

  Future<bool> delete(int businessId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await deleteBusiness(DeleteBusinessParams(businessId));
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

  void reset() => state = const BusinessFormState();
}