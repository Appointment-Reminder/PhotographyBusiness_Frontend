// business_form_state.dart — separate from the list
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';

class BusinessFormState extends Equatable {
  final Business? saved;     // null until a create/update succeeds
  final bool isSubmitting;
  final String? error;

  const BusinessFormState({this.saved, this.isSubmitting = false, this.error});

  BusinessFormState copyWith({Business? saved, bool? isSubmitting, String? error}) =>
      BusinessFormState(
        saved: saved ?? this.saved,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  @override
  List<Object?> get props => [saved, isSubmitting, error];
}