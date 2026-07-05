// business_member_list_state.dart
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';

class BusinessMemberListState extends Equatable {
  final List<BusinessMember> members;
  final bool isLoading;
  final String? error;

  const BusinessMemberListState({this.members = const [], this.isLoading = false, this.error});

  BusinessMemberListState copyWith({List<BusinessMember>? members, bool? isLoading, String? error}) =>
      BusinessMemberListState(
        members: members ?? this.members,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [members, isLoading, error];
}