// business_member_form_state.dart — invite/update/remove
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';

class BusinessMemberFormState extends Equatable {
  final BusinessMember? saved;
  final bool isSubmitting;
  final String? error;

  const BusinessMemberFormState({this.saved, this.isSubmitting = false, this.error});

  BusinessMemberFormState copyWith({BusinessMember? saved, bool? isSubmitting, String? error}) =>
      BusinessMemberFormState(
        saved: saved ?? this.saved,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  @override
  List<Object?> get props => [saved, isSubmitting, error];
}