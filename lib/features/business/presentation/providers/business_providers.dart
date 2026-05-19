import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource_impl.dart';
import 'package:photography_business_frontend/features/business/data/repositories/business_repository_impl.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_repository.dart';
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
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_member_state.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';

import '../../domain/usecases/create_business.dart';

final businessRemoteDataSourceProvider = Provider<BusinessRemoteDatasource>((ref) {
  return BusinessRemoteDatasourceImpl(client: ref.read(dioProvider));
});

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl(
    remoteDatasource: ref.read(businessRemoteDataSourceProvider),
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
  return GetBusinessMembersUser(repository: ref.read(businessRepositoryProvider));
});

final getMyBusinessUserProvider = Provider<GetMyBusinessesUser>((ref){
  return GetMyBusinessesUser(repository: ref.read(businessRepositoryProvider));
});

final inviteBusinessMemberUserProvider = Provider<InviteMemberUser>((ref){
  return InviteMemberUser(repository:  ref.read(businessRepositoryProvider));
});

final removeMemberUserProvider = Provider<RemoveMemberUser>((ref){
  return RemoveMemberUser(repository: ref.read(businessRepositoryProvider));
});

final updateBusinessProvider = Provider<UpdateBusinessUser>((ref){
  return UpdateBusinessUser(repository: ref.read(businessRepositoryProvider));
});

final updateMemberRoleUserProvider = Provider<UpdateMemberRoleUser>((ref){
  return UpdateMemberRoleUser(repository: ref.read(businessRepositoryProvider));
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