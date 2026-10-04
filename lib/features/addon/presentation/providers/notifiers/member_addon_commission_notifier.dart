import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/addon.dart';
import '../../../domain/entities/addon_commission.dart';
import '../../../domain/repositories/addon_repository.dart';

class MemberAddonCommissionState extends Equatable {
  /// Active Add-ons only.
  final List<Addon> addons;

  /// memberId -> addonId -> commission in effect now.
  final Map<int, Map<int, AddonCommission>> commissions;
  final bool isLoading;
  final String? error;

  const MemberAddonCommissionState({
    this.addons = const [],
    this.commissions = const {},
    this.isLoading = false,
    this.error,
  });

  /// The Member's commission on an Add-on; a flat 0 when there is none.
  AddonCommission commissionFor(int memberId, int addonId) =>
      commissions[memberId]?[addonId] ??
      AddonCommission(
        businessMemberId: memberId,
        addonId: addonId,
        commissionAmount: 0,
        commissionIsPercentage: false,
        effectiveFrom: DateTime.fromMillisecondsSinceEpoch(0),
      );

  MemberAddonCommissionState copyWith({
    List<Addon>? addons,
    Map<int, Map<int, AddonCommission>>? commissions,
    bool? isLoading,
    String? error,
  }) =>
      MemberAddonCommissionState(
        addons: addons ?? this.addons,
        commissions: commissions ?? this.commissions,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [addons, commissions, isLoading, error];
}

class MemberAddonCommissionNotifier extends StateNotifier<MemberAddonCommissionState> {
  final AddonRepository repository;

  MemberAddonCommissionNotifier({required this.repository})
      : super(const MemberAddonCommissionState());

  /// Reads the active Add-ons and the Member's current commission on each, in
  /// one call. The backend fills in a flat 0 where there is none.
  Future<void> loadForMember({required int businessId, required int memberId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final listed = await repository.getAddons(businessId);
    final all = listed.fold<List<Addon>?>((_) => null, (a) => a);
    if (all == null) {
      state = state.copyWith(
          isLoading: false, error: listed.fold((f) => f.message, (_) => null));
      return;
    }
    final addons = all.where((a) => a.isActive).toList();
    final result =
        await repository.listMemberAddonCommissions(businessId: businessId, memberId: memberId);
    result.fold(
      (f) => state = state.copyWith(
        isLoading: false,
        addons: addons,
        commissions: {...state.commissions}..remove(memberId),
        error: f.message,
      ),
      (list) => state = state.copyWith(
        isLoading: false,
        addons: addons,
        commissions: {
          ...state.commissions,
          memberId: {for (final c in list) c.addonId: c},
        },
      ),
    );
  }

  /// Saves a Member's commission on an Add-on. One that already has a stored
  /// version is corrected in place; one still on the flat 0 default gets its
  /// first version, effective now (earlier Appointments keep their frozen
  /// commission either way). [value] must be a whole, non-negative number.
  /// Returns null on success, or the error message; on failure the previous
  /// value is kept.
  Future<String?> save({
    required int memberId,
    required int addonId,
    required String value,
    required bool isPercentage,
  }) async {
    final amount = int.tryParse(value.trim());
    if (amount == null || amount < 0) return 'Enter a whole number, 0 or more';
    final existingId = state.commissions[memberId]?[addonId]?.id;
    final result = existingId == null
        ? await repository.createAddonCommission(
            memberId: memberId,
            addonId: addonId,
            commissionAmount: amount,
            commissionIsPercentage: isPercentage,
            effectiveFrom: DateTime.now(),
          )
        : await repository.updateAddonCommission(
            id: existingId,
            commissionAmount: amount,
            commissionIsPercentage: isPercentage,
          );
    return result.fold((f) {
      state = state.copyWith(error: f.message);
      return f.message;
    }, (c) {
      state = state.copyWith(commissions: {
        ...state.commissions,
        memberId: {...?state.commissions[memberId], addonId: c},
      });
      return null;
    });
  }
}
