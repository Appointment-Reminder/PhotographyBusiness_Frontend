// member_webhook_forms_state.dart  (was MemberFormState)
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member_form.dart';

class MemberWebhookFormsState extends Equatable {
  final List<BusinessMemberForm> forms;
  final bool isLoading;
  final String? error;

  const MemberWebhookFormsState({this.forms = const [], this.isLoading = false, this.error});

  MemberWebhookFormsState copyWith({List<BusinessMemberForm>? forms, bool? isLoading, String? error}) =>
      MemberWebhookFormsState(
        forms: forms ?? this.forms,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [forms, isLoading, error];
}