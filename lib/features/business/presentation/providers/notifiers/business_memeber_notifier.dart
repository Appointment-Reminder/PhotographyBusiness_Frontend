import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_members.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/invite_member.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/update_member_role.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/remove_member.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_member_state.dart';

import '../../../domain/usecases/business_params.dart';

class BusinessMemberNotifier extends StateNotifier<BusinessMemberState> {
  final GetBusinessMembersUser getBusinessMembers;
  final InviteMemberUser inviteMember;
  final UpdateMemberRoleUser updateMemberRole;
  final RemoveMemberUser removeMember;

  BusinessMemberNotifier({
    required this.getBusinessMembers,
    required this.inviteMember,
    required this.updateMemberRole,
    required this.removeMember,
  }) : super( MemberInitial()); // <-- Initialize with const state

  Future<void> loadMembers(int businessId) async {
    state =  MemberLoading();

    final result = await getBusinessMembers(GetBusinessMembersParams(businessId));

    result.fold(
          (failure) => state = MemberError(message: failure.message),
          (members) => state = MembersLoaded(members: members),
    );
  }

  Future<void> inviteNewMember(
      int businessId,
      String userEmail,
      String role,
      ) async {
    state = MemberLoading();

    final result = await inviteMember(
      InviteMemberParams(
        businessId: businessId,
        userEmail: userEmail,
        role: role,
      ),
    );

    result.fold(
          (failure) => state = MemberError(message: failure.message),
          (_) => loadMembers(businessId), // Reload members after invite
    );
  }

  Future<void> updateRole(
      int businessId,
      int memberId,
      String role,
      bool isActive,
      ) async {
    state = MemberLoading();

    final result = await updateMemberRole(
      UpdateMemberRoleParams(
        businessId: businessId,
        memberId: memberId,
        role: role,
        isActive: isActive,
      ),
    );

    result.fold(
          (failure) => state = MemberError(message: failure.message),
          (_) => loadMembers(businessId), // Reload members after update
    );
  }

  Future<void> removeMemberFromBusiness(int businessId, int memberId) async {
    state = MemberLoading();

    final result = await removeMember(
      RemoveMemberParams(businessId: businessId, memberId: memberId),
    );

    result.fold(
          (failure) => state = MemberError(message: failure.message),
          (_) => loadMembers(businessId), // Reload members after removal
    );
  }
}