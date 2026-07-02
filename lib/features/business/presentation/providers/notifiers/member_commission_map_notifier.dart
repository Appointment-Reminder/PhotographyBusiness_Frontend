
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_members.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/member_params.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_by_id.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_packages_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';

class MemberCommissionMapState {
  final List<BusinessMember> members;
  final Map<int, List<MemberCommission>> commissionByMembers;
  final Map<int, Package> packageByCommission;
  final bool isLoading;
  final String? error;

  const MemberCommissionMapState({this.members = const [], this.commissionByMembers = const {}, this.packageByCommission = const {}, this.isLoading = false, this.error});


  MemberCommissionMapState copyWith({
    List<BusinessMember>? members,
    Map<int, List<MemberCommission>>? commissionByMembers,
    Map<int, Package>? packageByCommission,
    bool? isLoading,
    String? error,
  }) {
    return MemberCommissionMapState(
      members: members ?? this.members,
      commissionByMembers: commissionByMembers ?? this.commissionByMembers,
      packageByCommission: packageByCommission ?? this.packageByCommission,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MemberCommissionMapNotifier extends StateNotifier<MemberCommissionMapState> {
  final GetBusinessMembersUser getBusinessMember;
  final GetMemberCommissionUser getMemberCommissionUser;
  final GetPackagesForBusiness getPackages;
  final GetPackageById getPackageById;

  MemberCommissionMapNotifier({
    required this.getBusinessMember,
    required this.getMemberCommissionUser,
    required this.getPackageById, required this.getPackages}) : super (const MemberCommissionMapState());

  Future<void> loadForBusiness(int businessId) async {
    state = state.copyWith(isLoading: true, error:null);

    final memberResult = await getBusinessMember(
      GetBusinessMembersParams( businessId),
    );

    final pkgsResult = await getPackages(
      GetPackagesForBusinessParams(businessId: businessId),
    );

    if (memberResult.isLeft() || pkgsResult.isLeft()) {
      final message = memberResult.fold((f) => f.message, (_) => null) ??
          pkgsResult.fold((f) => f.message, (_) => null) ??
          'Failed to load packages';
      state = state.copyWith(isLoading: false, error: message);
      return;
    }

    final members = memberResult.getOrElse(() => []);
    final packages = pkgsResult.getOrElse(() => []);

    await Future.wait(members.map( (p) => loadCommission(p.id, ));
  }

  Future<void> loadPackages(int businessId) async{

  }
  
  Future<void> loadCommission(int memberId, int businessId) async {
    final result = await getMemberCommissionUser(
      GetMemberCommissionParams(memberId: memberId, packageId: packageId)
    );
  }

}