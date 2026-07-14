import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member_form.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_member_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/CreateMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/DeleteMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberFormsUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/UpdateMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/get_all_member_forms_user.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_members.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/invite_member.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/remove_member.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/update_member_role.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/member/business_member_list_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/member/form/business_member_form_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/member/form/member_forms_map_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/member/business_member_list_state.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/member/form/business_member_form_state.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/repositories/business_member_repository_impl.dart';

final businessMemberRepositoryProvider = Provider<BusinessMemberRepository>((ref){
  return BusinessMemberRepositoryImpl(
      remoteDatasource: ref.read(businessRemoteDataSourceProvider),
      networkInfo: ref.read(networkInfoProvider)
  );
});

final getBusinessMembersUserProvider = Provider<GetBusinessMembersUser>((ref){
  return GetBusinessMembersUser(repository: ref.read(businessMemberRepositoryProvider));
});

final inviteBusinessMemberUserProvider = Provider<InviteMemberUser>((ref){
  return InviteMemberUser(repository:  ref.read(businessMemberRepositoryProvider));
});

final removeMemberUserProvider = Provider<RemoveMemberUser>((ref){
  return RemoveMemberUser(repository: ref.read(businessMemberRepositoryProvider));
});

final updateMemberRoleUserProvider = Provider<UpdateMemberRoleUser>((ref){
  return UpdateMemberRoleUser(repository: ref.read(businessMemberRepositoryProvider));
});

final createMemberFormUserProvider = Provider<CreateMemberFormUser>((ref){
  return CreateMemberFormUser(repository: ref.read(memberAdminRepositoryProvider));
});

final updateMemberFormUserProvider = Provider<UpdateMemberFormUser>((ref){
  return UpdateMemberFormUser(repository: ref.read(memberAdminRepositoryProvider));
});
final getMemberFormsUserProvider = Provider<GetMemberFormsUser>((ref){
  return GetMemberFormsUser(repository: ref.read(memberAdminRepositoryProvider));
});

final getAllMemberFormsUserProvider = Provider<GetAllMemberFormsUser>((ref){
  return GetAllMemberFormsUser(repository: ref.read(memberAdminRepositoryProvider));
});

final deleteMemberFormUserProvider = Provider<DeleteMemberFormUser>((ref){
  return DeleteMemberFormUser(repository: ref.read(memberAdminRepositoryProvider));
});

final memberFormsMapProvider = StateNotifierProvider<MemberFormsMapNotifier, Map<int, List<BusinessMemberForm>>>((ref) {
  return MemberFormsMapNotifier(ref.read(memberAdminRepositoryProvider));
});

/// SINGLE SOURCE OF TRUTH for a business's member list, keyed by businessId.
/// Any feature that needs members (commissions, jotform, appointment
/// photographer picker, etc.) watches this instead of fetching/caching its
/// own copy. Auto-loads on first watch/read.
final businessMembersProvider =
StateNotifierProvider.family<BusinessMemberListNotifier, BusinessMemberListState, int>((ref, businessId) {
  final notifier = BusinessMemberListNotifier(getBusinessMembers: ref.read(getBusinessMembersUserProvider));
  notifier.load(businessId);
  return notifier;
});

final businessMemberFormNotifierProvider =
StateNotifierProvider<BusinessMemberFormNotifier, BusinessMemberFormState>((ref) {
  return BusinessMemberFormNotifier(
    inviteMember: ref.read(inviteBusinessMemberUserProvider),
    updateMemberRole: ref.read(updateMemberRoleUserProvider),
    removeMember: ref.read(removeMemberUserProvider),
    ref: ref,
  );
});