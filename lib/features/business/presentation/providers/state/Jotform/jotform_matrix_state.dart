import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member_form.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';

class JotformMatrixState {
  final List<BusinessMember> members;
  final List<PackageCategory> categories;
  final Map<int, List<BusinessMemberForm>> forms; // memberId -> forms
  final bool isLoading;
  final String? error;

  const JotformMatrixState({
    this.members = const [],
    this.categories = const [],
    this.forms = const {},
    this.isLoading = false,
    this.error,
  });

  BusinessMemberForm? findForm(int memberId, int categoryId) {
    final list = forms[memberId] ?? const [];
    for (final f in list) {
      if (f.categoryId == categoryId) return f;
    }
    return null;
  }

  Map<String, Set<String>> get configuredMap => {
    for (final entry in forms.entries)
      entry.key.toString(): entry.value.map((f) => f.categoryId.toString()).toSet(),
  };

  JotformMatrixState copyWith({
    List<BusinessMember>? members,
    List<PackageCategory>? categories,
    Map<int, List<BusinessMemberForm>>? forms,
    bool? isLoading,
    String? error,
  }) {
    return JotformMatrixState(
      members: members ?? this.members,
      categories: categories ?? this.categories,
      forms: forms ?? this.forms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}