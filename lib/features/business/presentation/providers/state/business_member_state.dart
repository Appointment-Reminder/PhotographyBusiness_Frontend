import 'package:equatable/equatable.dart';

import '../../../domain/entities/business_member.dart';

abstract class BusinessMemberState extends Equatable{
  const BusinessMemberState();

  @override
  List<Object?> get props => [];

}
class MemberInitial extends BusinessMemberState{
  const MemberInitial();
}
class MemberLoading extends BusinessMemberState {
  const MemberLoading();
}
class MembersLoaded extends BusinessMemberState {
  final List<BusinessMember> members;

  const MembersLoaded({required this.members});

  @override
  List<Object?> get props => [members];
}
class MemberError extends BusinessMemberState{
  final String message;

  const MemberError({required this.message});

  @override
  List<Object?> get props => [message];
}
