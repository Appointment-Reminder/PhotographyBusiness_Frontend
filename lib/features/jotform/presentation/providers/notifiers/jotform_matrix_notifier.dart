import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_params.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_usecases.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/get_package_categories_for_business.dart';
import 'package:photography_business_frontend/features/package/domain/usecases/package_params.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_assignment.dart';
import '../state/jotform_matrix_state.dart';

class JotformMatrixNotifier extends StateNotifier<JotformMatrixState> {
  final GetPackageCategoriesForBusiness getCategories;
  final GetJotformFormsForBusiness getForms;
  final GetJotformAssignments getAssignments;
  final AssignJotformForm assignForm;

  JotformMatrixNotifier({
    required this.getCategories,
    required this.getForms,
    required this.getAssignments,
    required this.assignForm,
  }) : super(const JotformMatrixState());

  Future<void> loadForBusiness(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);

    // fire all three, then await
    final catsF = getCategories(GetPackageCategoriesForBusinessParams(businessId: businessId));
    final formsF = getForms(JotformBusinessParams(businessId));
    final asgF = getAssignments(JotformBusinessParams(businessId));
    final cats = await catsF;
    final forms = await formsF;
    final asg = await asgF;

    if (cats.isLeft() || forms.isLeft() || asg.isLeft()) {
      state = state.copyWith(isLoading: false, error: 'Failed to load Jotform assignments');
      return;
    }

    final grouped = <int, Map<int, JotformAssignment>>{};
    for (final a in asg.getOrElse(() => [])) {
      (grouped[a.businessMemberId] ??= {})[a.categoryId] = a;
    }

    state = state.copyWith(
      isLoading: false,
      categories: cats.getOrElse(() => []),
      forms: forms.getOrElse(() => []),
      assignments: grouped,
    );
  }

  /// Assign (or re-assign) a form to a member/category pair.
  Future<bool> assign({required int formId, required int memberId, required int categoryId}) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final res = await assignForm(
        AssignFormParams(formId: formId, businessMemberId: memberId, categoryId: categoryId));
    return res.fold((f) {
      state = state.copyWith(isSubmitting: false, error: f.message);
      return false;
    }, (a) {
      state = state.copyWith(isSubmitting: false, assignments: {
        ...state.assignments,
        memberId: {...(state.assignments[memberId] ?? {}), categoryId: a},
      });
      return true;
    });
  }

  void clear() => state = const JotformMatrixState();
}
