// package_form_state.dart — create/update/delete package
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';

class PackageFormState extends Equatable {
  final Package? saved;
  final bool isSubmitting;
  final String? error;

  const PackageFormState({this.saved, this.isSubmitting = false, this.error});

  PackageFormState copyWith({Package? saved, bool? isSubmitting, String? error}) =>
      PackageFormState(
        saved: saved ?? this.saved,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  @override
  List<Object?> get props => [saved, isSubmitting, error];
}