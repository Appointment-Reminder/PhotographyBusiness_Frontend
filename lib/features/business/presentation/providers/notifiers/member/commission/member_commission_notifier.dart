
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/member/commission/member_commission_state.dart';
import '../../../../../domain/usecases/AdminUseCases/CreateMemberCommissionUser.dart';
import '../../../../../domain/usecases/AdminUseCases/GetMemberCommissionUser.dart';
import '../../../../../domain/usecases/member_params.dart';

class MemberCommissionNotifier extends StateNotifier<MemberCommissionState> {
  final CreateMemberCommissionUser createMemberCommission;
  final GetMemberCommissionUser getMemberCommission;

  MemberCommissionNotifier({required this.createMemberCommission, required this.getMemberCommission})
      : super(const MemberCommissionState());

  Future<void> load(int memberId, int packageId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await getMemberCommission(GetMemberCommissionParams(memberId: memberId, packageId: packageId));
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (c) => state = state.copyWith(isLoading: false, commission: c),
    );
  }

  Future<void> create({
    required int businessMemberId,
    required int packageId,
    required int commissionPercent,
    required DateTime effectiveFrom,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await createMemberCommission(CreateMemberCommissionParams(
      businessMemberId: businessMemberId,
      packageId: packageId,
      commissionPercent: commissionPercent,
      effectiveFrom: effectiveFrom,
    ));
    result.fold(
          (f) => state = state.copyWith(isLoading: false, error: f.message),
          (c) => state = state.copyWith(isLoading: false, commission: c),
    );
  }
}