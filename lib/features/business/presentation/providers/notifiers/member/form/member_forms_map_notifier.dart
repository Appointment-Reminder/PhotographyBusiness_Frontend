import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member_form.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';

// State: memberId → List<BusinessMemberForm>
class MemberFormsMapNotifier
    extends StateNotifier<Map<int, List<BusinessMemberForm>>> {
  final MemberAdminRepository repository;

  MemberFormsMapNotifier(this.repository) : super({});

  /// Load forms for one member and merge into the map
  Future<void> loadFormsForMember({
    required int businessId,
    required int memberId,
  }) async {
    final result = await repository.getMemberForms(
      businessId: businessId,
      memberId: memberId,
    );

    result.fold(
          (failure) {
        // keep existing data for other members, just skip this one
        // you could add per-member error state if needed later
      },
          (forms) {
        state = {
          ...state,
          memberId: forms,
        };
      },
    );
  }

  /// Load forms for all members in parallel
  Future<void> loadFormsForAllMembers({
    required int businessId,
    required List<int> memberIds,
  }) async {
    await Future.wait(
      memberIds.map(
            (memberId) => loadFormsForMember(
          businessId: businessId,
          memberId: memberId,
        ),
      ),
    );
  }

  /// Find existing form for a member + category pair
  BusinessMemberForm? findForm(int memberId, int categoryId) {
    final forms = state[memberId] ?? [];
    return forms.where((f) => f.categoryId == categoryId).firstOrNull;
  }

  /// Build configuredMap for the matrix:
  /// memberId(string) → Set<categoryId(string)>
  Map<String, Set<String>> get configuredMap {
    return state.map(
          (memberId, forms) => MapEntry(
        memberId.toString(),
        forms.map((f) => f.categoryId.toString()).toSet(),
      ),
    );
  }

  void clear() => state = {};
}