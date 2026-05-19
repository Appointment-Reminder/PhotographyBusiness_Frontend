import '../../../domain/entities/business_member.dart';

abstract class BusinessMemberState{
  const BusinessMemberState();
}
class MemberInitial extends BusinessMemberState{}
class MemberLoading extends BusinessMemberState {}
class MembersLoaded extends BusinessMemberState {
  final List<BusinessMember> members;

  const MembersLoaded({required this.members});
}
class MemberError extends BusinessMemberState{
  final String message;

  const MemberError({required this.message});
}
