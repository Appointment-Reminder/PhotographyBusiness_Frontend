// business_form_notifier.dart — WRITE ONLY, its own provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/create_business.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/Refacto/Business_form_state.dart';

class BusinessFormNotifier extends StateNotifier<BusinessFormState> {
  final CreateBusinessUser createBusiness;
  BusinessFormNotifier(this.createBusiness) : super(const BusinessFormState());

  Future<void> create(String name, String? description) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await createBusiness(CreateBusinessParams(name: name, description: description));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (b) => state = state.copyWith(isSubmitting: false, saved: b),
    );
  }
}