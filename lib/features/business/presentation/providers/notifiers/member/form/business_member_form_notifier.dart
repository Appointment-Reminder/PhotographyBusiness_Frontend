import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/member/form/business_member_form_state.dart';
import '../../../../../domain/usecases/invite_member.dart';
import '../../../../../domain/usecases/update_member_role.dart';
import '../../../../../domain/usecases/remove_member.dart';
import '../../../../../domain/usecases/business_params.dart';

class BusinessMemberFormNotifier extends StateNotifier<BusinessMemberFormState> {
  final InviteMemberUser inviteMember;
  final UpdateMemberRoleUser updateMemberRole;
  final RemoveMemberUser removeMember;
  final Ref ref;

  BusinessMemberFormNotifier({
    required this.inviteMember,
    required this.updateMemberRole,
    required this.removeMember,
    required this.ref,
  }) : super(const BusinessMemberFormState());

  Future<void> invite(int businessId, String email, String role) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await inviteMember(
      InviteMemberParams(businessId: businessId, userEmail: email, role: role),
    );
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (m) => state = state.copyWith(isSubmitting: false, saved: m),
    );
    await ref.read(businessMembersProvider(businessId).notifier).load(businessId);
  }

  Future<void> updateRole(int businessId, int memberId, String role, bool isActive) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await updateMemberRole(
      UpdateMemberRoleParams(businessId: businessId, memberId: memberId, role: role, isActive: isActive),
    );
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (m) => state = state.copyWith(isSubmitting: false, saved: m),
    );
    await ref.read(businessMembersProvider(businessId).notifier).load(businessId);
  }

  Future<void> remove(int businessId, int memberId) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await removeMember(RemoveMemberParams(businessId: businessId, memberId: memberId));
    result.fold(
          (f) => state = state.copyWith(isSubmitting: false, error: f.message),
          (_) => state = state.copyWith(isSubmitting: false),
    );
    await ref.read(businessMembersProvider(businessId).notifier).load(businessId);
  }
}