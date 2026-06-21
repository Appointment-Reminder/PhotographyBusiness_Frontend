import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource_impl.dart';
import 'package:photography_business_frontend/features/business/data/datasource/member_admin_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/data/datasource/member_admin_remote_datasource_impl.dart';
import 'package:photography_business_frontend/features/business/data/repositories/business_member_repository_impl.dart';
import 'package:photography_business_frontend/features/business/data/repositories/business_repository_impl.dart';
import 'package:photography_business_frontend/features/business/data/repositories/member_admin_repository_impl.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_member_repository.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_repository.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/CreateMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/CreateMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/DeleteMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberFormsUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/UpdateMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/delete_business.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_by_id.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_members.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_my_businesses.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/invite_member.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/remove_member.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/update_business.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/update_member_role.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/business_memeber_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/business_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_member_commission_state.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_member_form_state.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_member_state.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';

import '../../domain/usecases/create_business.dart';
import 'notifiers/MemberCommissionNotifier.dart' show MemberCommissionNotifier;
import 'notifiers/member_form_notifier.dart' show MemberFormNotifier;

final businessRemoteDataSourceProvider = Provider<BusinessRemoteDatasource>((ref) {
  return BusinessRemoteDatasourceImpl(client: ref.read(dioProvider));
});

final memberAdminRemoteDataSourceProvider = Provider<MemberAdminRemoteDatasource>((ref){
  return MemberAdminRemoteDatasourceImpl(client: ref.read(dioProvider));
});

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl(
    remoteDatasource: ref.read(businessRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider)
  );
});

final businessMemberRepositoryProvider = Provider<BusinessMemberRepository>((ref){
  return BusinessMemberRepositoryImpl(
      remoteDatasource: ref.read(businessRemoteDataSourceProvider),
      networkInfo: ref.read(networkInfoProvider)
  );
});

final memberAdminRepositoryProvider = Provider<MemberAdminRepository>((ref){
  return MemberAdminRepositoryImpl(
      remoteDatasource: ref.read(memberAdminRemoteDataSourceProvider),
      networkInfo: ref.read(networkInfoProvider)
  );
});

final createBusinessUserProvider = Provider<CreateBusinessUser>((ref){
  return CreateBusinessUser(repository: ref.read(businessRepositoryProvider));
});

final deleteBusinessUserProvider = Provider<DeleteBusinessUser>((ref){
  return DeleteBusinessUser(repository: ref.read(businessRepositoryProvider));
});

final getBusinessByIdUserProvider = Provider<GetBusinessByIdUser>((ref){
  return GetBusinessByIdUser(repository: ref.read(businessRepositoryProvider));
});

final getBusinessMembersUserProvider = Provider<GetBusinessMembersUser>((ref){
  return GetBusinessMembersUser(repository: ref.read(businessMemberRepositoryProvider));
});

final getMyBusinessUserProvider = Provider<GetMyBusinessesUser>((ref){
  return GetMyBusinessesUser(repository: ref.read(businessRepositoryProvider));
});

final inviteBusinessMemberUserProvider = Provider<InviteMemberUser>((ref){
  return InviteMemberUser(repository:  ref.read(businessMemberRepositoryProvider));
});

final removeMemberUserProvider = Provider<RemoveMemberUser>((ref){
  return RemoveMemberUser(repository: ref.read(businessMemberRepositoryProvider));
});

final updateBusinessProvider = Provider<UpdateBusinessUser>((ref){
  return UpdateBusinessUser(repository: ref.read(businessRepositoryProvider));
});

final updateMemberRoleUserProvider = Provider<UpdateMemberRoleUser>((ref){
  return UpdateMemberRoleUser(repository: ref.read(businessMemberRepositoryProvider));
});

final businessNotifierProvider = StateNotifierProvider<BusinessNotifier, BusinessState>((ref){
  return BusinessNotifier(
      getMyBusinessesUser: ref.read(getMyBusinessUserProvider),
      getBusinessByIdUser: ref.read(getBusinessByIdUserProvider),
      createBusinessUser: ref.read(createBusinessUserProvider),
      updateBusinessUser: ref.read(updateBusinessProvider),
      deleteBusinessUser: ref.read(deleteBusinessUserProvider),
  );
});

final businessMemberNotifierProvider = StateNotifierProvider<BusinessMemberNotifier, BusinessMemberState>((ref){
  return BusinessMemberNotifier(
      getBusinessMembers: ref.read(getBusinessMembersUserProvider),
      inviteMember: ref.read(inviteBusinessMemberUserProvider),
      updateMemberRole: ref.read(updateMemberRoleUserProvider),
      removeMember: ref.read(removeMemberUserProvider),
  );
});

final createMemberCommissionUserProvider = Provider<CreateMemberCommissionUser>((ref){
  return CreateMemberCommissionUser(repository: ref.read(memberAdminRepositoryProvider));
});
final getMemberCommissionUserProvider = Provider<GetMemberCommissionUser>((ref){
  return GetMemberCommissionUser(repository: ref.read(memberAdminRepositoryProvider));
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
final deleteMemberFormUserProvider = Provider<DeleteMemberFormUser>((ref){
  return DeleteMemberFormUser(repository: ref.read(memberAdminRepositoryProvider));
});

final memberCommissionNotifierProvider = StateNotifierProvider<MemberCommissionNotifier, MemberCommissionState>((ref){
  return MemberCommissionNotifier(
    createMemberCommission: ref.read(createMemberCommissionUserProvider),
    getMemberCommission: ref.read(getMemberCommissionUserProvider),
  );
});
final memberFormNotifierProvider = StateNotifierProvider<MemberFormNotifier, MemberFormState>((ref){
  return MemberFormNotifier(
    createMemberForm: ref.read(createMemberFormUserProvider),
    updateMemberForm: ref.read(updateMemberFormUserProvider),
    getMemberForms: ref.read(getMemberFormsUserProvider),
    deleteMemberForm: ref.read(deleteMemberFormUserProvider),
  );
});