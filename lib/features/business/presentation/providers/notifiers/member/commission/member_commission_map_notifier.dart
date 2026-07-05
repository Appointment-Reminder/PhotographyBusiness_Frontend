import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/CreateMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_members.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/member_params.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_categories_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_packages_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';

class MemberCommissionMapState {
  final List<BusinessMember> members;
  final List<Package> packages;
  // memberId -> packageId -> commission (absent = none set yet)
  final Map<int, Map<int, MemberCommission>> commissions;
  final List<PackageCategory> categories;
  final bool isLoading;
  final String? error;

  const MemberCommissionMapState({
    this.members = const [],
    this.packages = const [],
    this.commissions = const {},
    this.categories = const [],
    this.isLoading = false,
    this.error,
  });

  MemberCommissionMapState copyWith({
    List<BusinessMember>? members,
    List<Package>? packages,
    Map<int, Map<int, MemberCommission>>? commissions,
    List<PackageCategory>? categories,
    bool? isLoading,
    String? error,
  }) {
    return MemberCommissionMapState(
      members: members ?? this.members,
      packages: packages ?? this.packages,
      commissions: commissions ?? this.commissions,
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      error: error,
    );
  }
}

class MemberCommissionMapNotifier extends StateNotifier<MemberCommissionMapState> {
  final GetBusinessMembersUser getBusinessMembers;
  final GetMemberCommissionUser getMemberCommission;
  final GetPackagesForBusiness getPackages;
  final GetPackageCategoriesForBusiness getCategories;
  final CreateMemberCommissionUser createCommission; // add this usecase provider too

  MemberCommissionMapNotifier({
    required this.getBusinessMembers,
    required this.getMemberCommission,
    required this.getPackages,
    required this.getCategories,
    required this.createCommission,
  }) : super(const MemberCommissionMapState());

  Future<void> loadForBusiness(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);

    final memberResult = await getBusinessMembers(GetBusinessMembersParams(businessId));
    final pkgsResult = await getPackages(GetPackagesForBusinessParams(businessId: businessId));
    final catsResult = await getCategories(GetPackageCategoriesForBusinessParams(businessId: businessId));

    if (memberResult.isLeft() || pkgsResult.isLeft() || catsResult.isLeft()) {
      state = state.copyWith(isLoading: false, error: 'Failed to load team data');
      return;
    }

    final members = memberResult.getOrElse(() => []);
    final packages = pkgsResult.getOrElse(() => []);
    final categories = catsResult.getOrElse(() => []);

    state = state.copyWith(
      members: members,
      packages: packages,
      categories: categories,
      isLoading: false,
    );

    await Future.wait([
      for (final m in members)
        for (final p in packages)
          loadCommission(memberId: m.id, packageId: p.id),
    ]);
  }

  Future<void> loadCommission({required int memberId, required int packageId}) async {
    final result = await getMemberCommission(
      GetMemberCommissionParams(memberId: memberId, packageId: packageId),
    );

    result.fold(
          (_) {}, // no commission set for this pair yet — leave it absent, not an error
          (commission) {
        final updated = {...state.commissions};
        final forMember = {...(updated[memberId] ?? {})};
        forMember[packageId] = commission;
        updated[memberId] = forMember;
        state = state.copyWith(commissions: updated);
      },
    );
  }

  void clear() => state = const MemberCommissionMapState();
}