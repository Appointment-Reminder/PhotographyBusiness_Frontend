import 'package:equatable/equatable.dart';
import '../entities/field_mapping_item.dart';

/// Reused by: getCredentials, getFormsForBusiness, syncForms, getAssignments
class JotformBusinessParams extends Equatable {
  final int businessId;
  const JotformBusinessParams(this.businessId);
  @override
  List<Object?> get props => [businessId];
}

/// Reused by: refreshQuestions, getFieldMapping
class JotformFormParams extends Equatable {
  final int formId;
  const JotformFormParams(this.formId);
  @override
  List<Object?> get props => [formId];
}

/// Reused by: deleteCredential, getFormsForCredential
class JotformCredentialParams extends Equatable {
  final int credentialId;
  const JotformCredentialParams(this.credentialId);
  @override
  List<Object?> get props => [credentialId];
}

class CreateCredentialParams extends Equatable {
  final int businessId;
  final String label;
  final String apiKey;
  const CreateCredentialParams({required this.businessId, required this.label, required this.apiKey});
  @override
  List<Object?> get props => [businessId, label, apiKey];
}

class UpdateCredentialParams extends Equatable {
  final int id;
  final String label;
  final String apiKey;
  const UpdateCredentialParams({required this.id, required this.label, required this.apiKey});
  @override
  List<Object?> get props => [id, label, apiKey];
}

class UpdateFieldMappingParams extends Equatable {
  final int formId;
  final List<FieldMappingItem> mapping;
  const UpdateFieldMappingParams({required this.formId, required this.mapping});
  @override
  List<Object?> get props => [formId, mapping];
}

class AssignFormParams extends Equatable {
  final int formId;
  final int businessMemberId;
  final int categoryId;
  const AssignFormParams({required this.formId, required this.businessMemberId, required this.categoryId});
  @override
  List<Object?> get props => [formId, businessMemberId, categoryId];
}
