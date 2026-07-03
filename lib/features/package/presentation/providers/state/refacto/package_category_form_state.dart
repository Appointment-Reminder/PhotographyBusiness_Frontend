// package_category_form_state.dart — create/delete category
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';

class PackageCategoryFormState extends Equatable {
  final PackageCategory? saved;
  final bool isSubmitting;
  final String? error;

  const PackageCategoryFormState({this.saved, this.isSubmitting = false, this.error});

  PackageCategoryFormState copyWith({PackageCategory? saved, bool? isSubmitting, String? error}) =>
      PackageCategoryFormState(
        saved: saved ?? this.saved,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  @override
  List<Object?> get props => [saved, isSubmitting, error];
}