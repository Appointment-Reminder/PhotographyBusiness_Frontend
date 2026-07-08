import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/CreateMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/get_business_commissions_user.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/update_member_commission_user.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/member/commission/member_commission_map_notifier.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';

final createMemberCommissionUserProvider = Provider<CreateMemberCommissionUser>((ref){
  return CreateMemberCommissionUser(repository: ref.read(memberAdminRepositoryProvider));
});

final getMemberCommissionUserProvider = Provider<GetMemberCommissionUser>((ref){
  return GetMemberCommissionUser(repository: ref.read(memberAdminRepositoryProvider));
});

final getBusinessCommissionUserProvider = Provider<GetBusinessCommissionsUser>((ref){
  return GetBusinessCommissionsUser(repository: ref.read(memberAdminRepositoryProvider));
});

final updateMemberCommissionUserProvider = Provider<UpdateMemberCommissionUser>((ref){
  return UpdateMemberCommissionUser(repository: ref.read(memberAdminRepositoryProvider));
});


final memberCommissionMapProvider =
StateNotifierProvider<MemberCommissionMapNotifier, MemberCommissionMapState>((ref) {
  return MemberCommissionMapNotifier(
    getBusinessMembers: ref.read(getBusinessMembersUserProvider),
    getMemberCommission: ref.read(getMemberCommissionUserProvider),
    getCategories: ref.read(getPackageCategoriesForBusinessProvider),
    createCommission: ref.read(createMemberCommissionUserProvider),
    getPackages: ref.read(getPackagesForBusinessProvider),
    getBusinessCommissions: ref.read(getBusinessCommissionUserProvider),
    updateCommission: ref.read(updateMemberCommissionUserProvider),

  );
});