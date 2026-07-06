import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member_form.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/CreateMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/DeleteMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberFormsUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/UpdateMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/get_all_member_forms_user.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_members.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/member_params.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_categories_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';

import '../../state/Jotform/jotform_matrix_state.dart';

class JotformMatrixNotifier extends StateNotifier<JotformMatrixState> {
  final GetBusinessMembersUser getBusinessMembers;
  final GetPackageCategoriesForBusiness getCategories;
  final GetMemberFormsUser getMemberForms;
  final CreateMemberFormUser createMemberForm;
  final UpdateMemberFormUser updateMemberForm;
  final DeleteMemberFormUser deleteMemberForm;
  final GetAllMemberFormsUser getAllMemberForm;

  JotformMatrixNotifier({
    required this.getBusinessMembers,
    required this.getCategories,
    required this.getMemberForms,
    required this.createMemberForm,
    required this.updateMemberForm,
    required this.deleteMemberForm,
    required this.getAllMemberForm,
  }) : super(const JotformMatrixState());

  Future<void> loadForBusiness(int businessId) async {



    state = state.copyWith(isLoading: true, error: null);

    final memberResult = await getBusinessMembers(GetBusinessMembersParams(businessId));
    final catResult = await getCategories(GetPackageCategoriesForBusinessParams(businessId: businessId));
    final formsResult = await getAllMemberForm(GetBusinessByIdParams(businessId));

    if (memberResult.isLeft() || catResult.isLeft()) {
      state = state.copyWith(isLoading: false, error: 'Failed to load team / categories');
      return;
    }

    final members = memberResult.getOrElse(() => []);
    final categories = catResult.getOrElse(() => []);
    final flat = formsResult.getOrElse(() => []);

    final grouped = <int, List<BusinessMemberForm>>{};
    for (final f in flat) {
      grouped.putIfAbsent(f.businessMemberId, () => []).add(f);
    }

    state = state.copyWith(members: members, categories: categories, forms: grouped, isLoading: false);
  }

  Future<void> _loadFormsForMember(int businessId, int memberId) async {
    final result = await getMemberForms(GetMemberFormsParams(businessId: businessId, memberId: memberId));
    result.fold(
          (_) {}, // no forms yet for this member — not an error
          (forms) => state = state.copyWith(forms: {...state.forms, memberId: forms}),
    );
  }

  Future<void> saveForm({
    required int businessId,
    required int memberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    final existing = state.findForm(memberId, categoryId);

    if (existing != null) {
      await updateMemberForm(UpdateMemberFormParams(
        id: existing.id,
        businessMemberId: memberId,
        categoryId: categoryId,
        jotformFieldMap: jotformFieldMap,
      ));
    } else {
      await createMemberForm(CreateMemberFormParams(
        businessMemberId: memberId,
        categoryId: categoryId,
        jotformFieldMap: jotformFieldMap,
      ));
    }

    await _loadFormsForMember(businessId, memberId);
  }

  Future<void> removeForm({
    required int businessId,
    required int memberId,
    required int formId,
  }) async {
    await deleteMemberForm(DeleteMemberFormParams(formId));
    await _loadFormsForMember(businessId, memberId);
  }

  void clear() => state = const JotformMatrixState();
}