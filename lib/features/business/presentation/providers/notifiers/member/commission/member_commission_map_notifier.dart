import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/CreateMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberCommissionUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/get_business_commissions_user.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/update_member_commission_user.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/member_params.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_categories_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_packages_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';

/// No longer holds `members` — that lives in businessMembersProvider.
/// This state is purely commission/package/category data for a business.
class MemberCommissionMapState {
  final List<Package> packages;
  final List<PackageCategory> categories;
  // memberId -> packageId -> commission (absent = none set yet)
  final Map<int, Map<int, MemberCommission>> commissions;
  final bool isLoading;
  final String? error;

  const MemberCommissionMapState({
    this.packages = const [],
    this.categories = const [],
    this.commissions = const {},
    this.isLoading = false,
    this.error,
  });

  MemberCommissionMapState copyWith({
    List<Package>? packages,
    List<PackageCategory>? categories,
    Map<int, Map<int, MemberCommission>>? commissions,
    bool? isLoading,
    String? error,
  }) {
    return MemberCommissionMapState(
      packages: packages ?? this.packages,
      categories: categories ?? this.categories,
      commissions: commissions ?? this.commissions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MemberCommissionMapNotifier extends StateNotifier<MemberCommissionMapState> {
  final GetMemberCommissionUser getMemberCommission;
  final GetPackagesForBusiness getPackages;
  final GetPackageCategoriesForBusiness getCategories;
  final GetBusinessCommissionsUser getBusinessCommissions;
  final CreateMemberCommissionUser createCommission;
  final UpdateMemberCommissionUser updateCommission;

  MemberCommissionMapNotifier({
    required this.getMemberCommission,
    required this.getPackages,
    required this.getCategories,
    required this.createCommission,
    required this.getBusinessCommissions,
    required this.updateCommission,
  }) : super(const MemberCommissionMapState());

  Future<void> loadForBusiness(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);

    final pkgsResult = await getPackages(GetPackagesForBusinessParams(businessId: businessId));
    final catsResult = await getCategories(GetPackageCategoriesForBusinessParams(businessId: businessId));
    final commissionResult = await getBusinessCommissions(GetBusinessByIdParams(businessId));

    if (pkgsResult.isLeft() || catsResult.isLeft() || commissionResult.isLeft()) {
      state = state.copyWith(isLoading: false, error: 'Failed to load team data');
      return;
    }

    final packages = pkgsResult.getOrElse(() => []);
    final categories = catsResult.getOrElse(() => []);
    final flat = commissionResult.getOrElse(() => []);

    final grouped = <int, Map<int, MemberCommission>>{};
    for (final c in flat) {
      grouped.putIfAbsent(c.businessMemberId, () => {})[c.packageId] = c;
    }

    state = state.copyWith(packages: packages, categories: categories, commissions: grouped, isLoading: false);
  }

  Future<void> loadCommission({required int memberId, required int packageId}) async {
    final result = await getMemberCommission(
      GetMemberCommissionParams(memberId: memberId, packageId: packageId),
    );

    result.fold(
          (_) {},
          (commission) {
        final updated = {...state.commissions};
        final forMember = {...(updated[memberId] ?? {})};
        forMember[packageId] = commission;
        updated[memberId] = forMember;
        state = state.copyWith(commissions: updated);
      },
    );
  }

  Future<void> upsertCommission({
    required int memberId,
    required int packageId,
    required int commissionAmount,
    required bool commissionIsPercentage,
  }) async {
    final existing = state.commissions[memberId]?[packageId];

    final result = existing != null
        ? await updateCommission(UpdateMemberCommissionParams(
        id: existing.id, commissionAmount: commissionAmount, commissionIsPercentage: commissionIsPercentage))
        : await createCommission(CreateMemberCommissionParams(
      businessMemberId: memberId,
      packageId: packageId,
      commissionAmount: commissionAmount,
      commissionIsPercentage: commissionIsPercentage,
      effectiveFrom: DateTime.now(),
    ));

    result.fold((_) {}, (c) => _setCommission(memberId, packageId, c));
  }

  void _setCommission(int memberId, int packageId, MemberCommission c) {
    final updated = {...state.commissions};
    updated[memberId] = {...(updated[memberId] ?? {}), packageId: c};
    state = state.copyWith(commissions: updated);
  }

  void clear() => state = const MemberCommissionMapState();
}