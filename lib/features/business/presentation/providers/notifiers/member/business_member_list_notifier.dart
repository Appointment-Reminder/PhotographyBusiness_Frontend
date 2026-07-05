// business_member_list_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/member/business_member_list_state.dart';
import '../../../../domain/usecases/get_business_members.dart';
import '../../../../domain/usecases/business_params.dart';

class BusinessMemberListNotifier extends StateNotifier<BusinessMemberListState> {
  final GetBusinessMembersUser getBusinessMembers;

  BusinessMemberListNotifier({required this.getBusinessMembers})
      : super(const BusinessMemberListState());

  Future<void> load(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getBusinessMembers(GetBusinessMembersParams(businessId));
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (members) => state = state.copyWith(isLoading: false, members: members),
    );
  }
}