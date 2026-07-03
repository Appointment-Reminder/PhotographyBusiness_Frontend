// business_list_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/Refacto/BusinessListState.dart';
import '../../../domain/usecases/get_my_businesses.dart';
import '../../../domain/usecases/business_params.dart';

class BusinessListNotifier extends StateNotifier<BusinessListState> {
  final GetMyBusinessesUser getMyBusinesses;

  BusinessListNotifier({required this.getMyBusinesses}) : super(const BusinessListState());

  Future<void> load({bool? isActive}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getMyBusinesses(GetMyBusinessesParams(isActive: isActive));
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (list) => state = state.copyWith(isLoading: false, businesses: list),
    );
  }
}