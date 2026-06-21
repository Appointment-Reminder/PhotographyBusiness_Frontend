// business_member_commission_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/usecases/AdminUseCases/CreateMemberCommissionUser.dart';
import '../../../domain/usecases/AdminUseCases/GetMemberCommissionUser.dart';
import '../../../domain/usecases/member_params.dart';
import '../state/business_member_commission_state.dart';

class MemberCommissionNotifier extends StateNotifier<MemberCommissionState> {
  final CreateMemberCommissionUser createMemberCommission;
  final GetMemberCommissionUser getMemberCommission;

  MemberCommissionNotifier({required this.createMemberCommission, required this.getMemberCommission})
      : super(const MemberCommissionInitial());

  Future<void> loadCommission(int memberId, int packageId) async {
    state = const MemberCommissionLoading();
    final result = await getMemberCommission(GetMemberCommissionParams(memberId: memberId, packageId: packageId));
    result.fold(
          (failure) => state = MemberCommissionError(message: failure.message),
          (commission) => state = MemberCommissionLoaded(commission: commission),
    );
  }

  Future<void> createNewCommission({
    required int businessMemberId,
    required int packageId,
    required int commissionPercent,
    required DateTime effectiveFrom,
  }) async {
    state = const MemberCommissionLoading();
    final result = await createMemberCommission(CreateMemberCommissionParams(
      businessMemberId: businessMemberId,
      packageId: packageId,
      commissionPercent: commissionPercent,
      effectiveFrom: effectiveFrom,
    ));
    result.fold(
          (failure) => state = MemberCommissionError(message: failure.message),
          (commission) => state = MemberCommissionLoaded(commission: commission),
    );
  }
}