// business_member_form_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/CreateMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/DeleteMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/GetMemberFormsUser.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/AdminUseCases/UpdateMemberFormUser.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_member_form_state.dart';

import '../../../domain/usecases/member_params.dart';

class MemberFormNotifier extends StateNotifier<MemberFormState> {
  final CreateMemberFormUser createMemberForm;
  final UpdateMemberFormUser updateMemberForm;
  final GetMemberFormsUser getMemberForms;
  final DeleteMemberFormUser deleteMemberForm;

  MemberFormNotifier({
    required this.createMemberForm,
    required this.updateMemberForm,
    required this.getMemberForms,
    required this.deleteMemberForm,
  }) : super(const MemberFormInitial());

  Future<void> loadForms(int businessId, int businessMemberId) async {
    state = const MemberFormLoading();
    final result = await getMemberForms(GetMemberFormsParams(businessId: businessId, memberId: businessMemberId));
    result.fold(
          (failure) => state = MemberFormError(message: failure.message),
          (forms) => state = MemberFormListLoaded(forms: forms),
    );
  }

  Future<void> createNewForm({
    required int businessId,
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    state = const MemberFormLoading();
    final result = await createMemberForm(CreateMemberFormParams(
      businessMemberId: businessMemberId, categoryId: categoryId, jotformFieldMap: jotformFieldMap,
    ));
    result.fold(
          (failure) => state = MemberFormError(message: failure.message),
          (_) => loadForms(businessId, businessMemberId),
    );
  }

  Future<void> updateExistingForm({
    required int businessId,
    required int formId,
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    state = const MemberFormLoading();
    final result = await updateMemberForm(UpdateMemberFormParams(
      id: formId, businessMemberId: businessMemberId, categoryId: categoryId, jotformFieldMap: jotformFieldMap,
    ));
    result.fold(
          (failure) => state = MemberFormError(message: failure.message),
          (_) => loadForms(businessId, businessMemberId),
    );
  }

  Future<void> deleteForm({required int businessId, required int businessMemberId, required int formId}) async {
    state = const MemberFormLoading();
    final result = await deleteMemberForm(DeleteMemberFormParams(formId));
    result.fold(
          (failure) => state = MemberFormError(message: failure.message),
          (_) => loadForms(businessId, businessMemberId),
    );
  }
}