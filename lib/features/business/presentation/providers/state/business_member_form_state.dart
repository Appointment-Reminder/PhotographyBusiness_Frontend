import 'package:equatable/equatable.dart';
import '../../../domain/entities/business_member_form.dart';

abstract class MemberFormState extends Equatable {
  const MemberFormState();
  @override
  List<Object?> get props => [];
}

class MemberFormInitial extends MemberFormState {
  const MemberFormInitial();
}

class MemberFormLoading extends MemberFormState {
  const MemberFormLoading();
}

class MemberFormListLoaded extends MemberFormState {
  final List<BusinessMemberForm> forms;
  const MemberFormListLoaded({required this.forms});
  @override
  List<Object?> get props => [forms];
}

class MemberFormError extends MemberFormState {
  final String message;
  const MemberFormError({required this.message});
  @override
  List<Object?> get props => [message];
}