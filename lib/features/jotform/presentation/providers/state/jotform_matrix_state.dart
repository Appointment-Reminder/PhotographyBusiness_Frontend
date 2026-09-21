import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_assignment.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_form.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';

class JotformMatrixState extends Equatable {
  final List<PackageCategory> categories;
  final List<JotformForm> forms;                               // forms available for the business
  final Map<int, Map<int, JotformAssignment>> assignments;     // memberId -> categoryId -> assignment
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const JotformMatrixState({
    this.categories = const [],
    this.forms = const [],
    this.assignments = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  JotformAssignment? assignmentFor(int memberId, int categoryId) => assignments[memberId]?[categoryId];

  JotformForm? formFor(int memberId, int categoryId) {
    final a = assignmentFor(memberId, categoryId);
    if (a == null) return null;
    for (final f in forms) {
      if (f.id == a.formId) return f;
    }
    return null;
  }

  /// Same shape the existing matrix widgets already consume.
  Map<String, Set<String>> get configuredMap => {
        for (final e in assignments.entries)
          e.key.toString(): e.value.keys.map((c) => c.toString()).toSet(),
      };

  JotformMatrixState copyWith({
    List<PackageCategory>? categories,
    List<JotformForm>? forms,
    Map<int, Map<int, JotformAssignment>>? assignments,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) =>
      JotformMatrixState(
        categories: categories ?? this.categories,
        forms: forms ?? this.forms,
        assignments: assignments ?? this.assignments,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  @override
  List<Object?> get props => [categories, forms, assignments, isLoading, isSubmitting, error];
}
