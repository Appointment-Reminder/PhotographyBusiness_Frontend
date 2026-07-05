// business_detail_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business/business_detail_state.dart';
import '../../../../domain/usecases/get_business_by_id.dart';
import '../../../../domain/usecases/business_params.dart';


class BusinessDetailNotifier extends StateNotifier<BusinessDetailState> {
  final GetBusinessByIdUser getBusinessById;

  BusinessDetailNotifier({required this.getBusinessById}) : super(const BusinessDetailState());

  Future<void> load(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getBusinessById(GetBusinessByIdParams(businessId));
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (b) => state = state.copyWith(isLoading: false, business: b),
    );
  }

  void clear() => state = const BusinessDetailState();
}