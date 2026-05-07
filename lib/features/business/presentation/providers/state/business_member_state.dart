abstract class BusinessMemberState{}
class memberInitial extends BusinessMemberState{}
class MemberLoading extends BusinessMemberState {}
class MembersLoaded extends BusinessMemberState {
  final List<BusinessMember> members;
}
class memberError extends BusinessMemberState{
  final String message;
}
