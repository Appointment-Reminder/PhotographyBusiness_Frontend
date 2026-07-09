import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/Jotform/jotform_matrix_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/Jotform/jotform_matrix_state.dart';

import '../../../package/presentation/providers/package_providers.dart';

final jotformMatrixNotifierProvider =
StateNotifierProvider<JotformMatrixNotifier, JotformMatrixState>((ref) {
  return JotformMatrixNotifier(
    getBusinessMembers: ref.read(getBusinessMembersUserProvider),
    getCategories: ref.read(getPackageCategoriesForBusinessProvider), // from package_providers.dart
    getMemberForms: ref.read(getMemberFormsUserProvider),
    createMemberForm: ref.read(createMemberFormUserProvider),
    updateMemberForm: ref.read(updateMemberFormUserProvider),
    deleteMemberForm: ref.read(deleteMemberFormUserProvider),
    getAllMemberForm: ref.read(getAllMemberFormsUserProvider),
  );
});