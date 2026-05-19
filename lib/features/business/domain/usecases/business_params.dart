import 'package:equatable/equatable.dart';

// Get My Businesses
class GetMyBusinessesParams extends Equatable {
  final bool? isActive;

  const GetMyBusinessesParams({this.isActive});

  @override
  List<Object?> get props => [isActive];
}

// Get Business By ID
class GetBusinessByIdParams extends Equatable {
  final int businessId;

  const GetBusinessByIdParams(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

// Create Business
class CreateBusinessParams extends Equatable {
  final String name;
  final String? description;

  const CreateBusinessParams({
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [name, description];
}

// Update Business
class UpdateBusinessParams extends Equatable {
  final int businessId;
  final String? name;
  final String? description;

  const UpdateBusinessParams({
    required this.businessId,
    this.name,
    this.description,
  });

  @override
  List<Object?> get props => [businessId, name, description];
}

// Delete Business
class DeleteBusinessParams extends Equatable {
  final int businessId;

  const DeleteBusinessParams(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

// Get Business Members
class GetBusinessMembersParams extends Equatable {
  final int businessId;

  const GetBusinessMembersParams(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

// Invite Member
class InviteMemberParams extends Equatable {
  final int businessId;
  final String userEmail;
  final String role;

  const InviteMemberParams({
    required this.businessId,
    required this.userEmail,
    required this.role,
  });

  @override
  List<Object?> get props => [businessId, userEmail, role];
}

// Update Member Role
class UpdateMemberRoleParams extends Equatable {
  final int businessId;
  final int memberId;
  final String role;
  final bool isActive;

  const UpdateMemberRoleParams({
    required this.businessId,
    required this.memberId,
    required this.role,
    required this.isActive,
  });

  @override
  List<Object?> get props => [businessId, memberId, role, isActive];
}

// Remove Member
class RemoveMemberParams extends Equatable {
  final int businessId;
  final int memberId;

  const RemoveMemberParams({
    required this.businessId,
    required this.memberId,
  });

  @override
  List<Object?> get props => [businessId, memberId];
}