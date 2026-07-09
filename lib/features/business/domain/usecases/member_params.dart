// Create Member Commission
import 'package:equatable/equatable.dart';

class CreateMemberCommissionParams extends Equatable {
  final int businessMemberId;
  final int packageId;
  final int commissionAmount;
  final bool commissionIsPercentage;
  final DateTime effectiveFrom;

  const CreateMemberCommissionParams({
    required this.businessMemberId,
    required this.packageId,
    required this.commissionAmount,
    required this.commissionIsPercentage,
    required this.effectiveFrom,
  });

  @override
  List<Object?> get props => [businessMemberId, packageId, commissionAmount, commissionIsPercentage, effectiveFrom];
}

// Get Member Commission — note: API has NO business_id in this path
class GetMemberCommissionParams extends Equatable {
  final int memberId;
  final int packageId;

  const GetMemberCommissionParams({required this.memberId, required this.packageId});

  @override
  List<Object?> get props => [memberId, packageId];
}

// Create Member Form
class CreateMemberFormParams extends Equatable {
  final int businessMemberId;
  final int categoryId;
  final String jotformFieldMap;

  const CreateMemberFormParams({
    required this.businessMemberId,
    required this.categoryId,
    required this.jotformFieldMap,
  });

  @override
  List<Object?> get props => [businessMemberId, categoryId, jotformFieldMap];
}

// Update Member Form
class UpdateMemberFormParams extends Equatable {
  final int id;
  final int businessMemberId;
  final int categoryId;
  final String jotformFieldMap;

  const UpdateMemberFormParams({
    required this.id,
    required this.businessMemberId,
    required this.categoryId,
    required this.jotformFieldMap,
  });

  @override
  List<Object?> get props => [id, businessMemberId, categoryId, jotformFieldMap];
}

// Get Member Forms
class GetMemberFormsParams extends Equatable {
  final int businessId;
  final int memberId;

  const GetMemberFormsParams({required this.businessId, required this.memberId});

  @override
  List<Object?> get props => [businessId, memberId];
}

// Delete Member Form
class DeleteMemberFormParams extends Equatable {
  final int formId;

  const DeleteMemberFormParams(this.formId);

  @override
  List<Object?> get props => [formId];
}

class UpdateMemberCommissionParams extends Equatable {
  final int id;
  final int commissionAmount;
  final bool commissionIsPercentage;

  const UpdateMemberCommissionParams({required this.id, required this.commissionAmount, required this.commissionIsPercentage});

  @override
  List<Object?> get props => [id, commissionAmount, commissionIsPercentage];


}