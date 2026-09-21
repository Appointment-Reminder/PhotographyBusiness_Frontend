import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/field_mapping_item.dart';
import '../entities/jotform_assignment.dart';
import '../entities/jotform_credential.dart';
import '../entities/jotform_form.dart';
import '../entities/submission_field.dart';
import '../repositories/jotform_repository.dart';
import 'jotform_params.dart';

// ── Credentials ──────────────────────────────────────────────
class GetJotformCredentials extends Usecase<List<JotformCredential>, JotformBusinessParams> {
  final JotformRepository repository;
  GetJotformCredentials({required this.repository});
  @override
  Future<Either<Failure, List<JotformCredential>>> call(JotformBusinessParams p) =>
      repository.getCredentials(p.businessId);
}

class CreateJotformCredential extends Usecase<JotformCredential, CreateCredentialParams> {
  final JotformRepository repository;
  CreateJotformCredential({required this.repository});
  @override
  Future<Either<Failure, JotformCredential>> call(CreateCredentialParams p) {
    if (p.label.trim().isEmpty || p.apiKey.trim().isEmpty) {
      return Future.value(const Left(ServerFailure('Label and API key are required')));
    }
    return repository.createCredential(
        businessId: p.businessId, label: p.label.trim(), apiKey: p.apiKey.trim());
  }
}

class UpdateJotformCredential extends Usecase<JotformCredential, UpdateCredentialParams> {
  final JotformRepository repository;
  UpdateJotformCredential({required this.repository});
  @override
  Future<Either<Failure, JotformCredential>> call(UpdateCredentialParams p) {
    if (p.label.trim().isEmpty || p.apiKey.trim().isEmpty) {
      return Future.value(const Left(ServerFailure('Label and API key are required')));
    }
    return repository.updateCredential(id: p.id, label: p.label.trim(), apiKey: p.apiKey.trim());
  }
}

class DeleteJotformCredential extends Usecase<void, JotformCredentialParams> {
  final JotformRepository repository;
  DeleteJotformCredential({required this.repository});
  @override
  Future<Either<Failure, void>> call(JotformCredentialParams p) =>
      repository.deleteCredential(p.credentialId);
}

// ── Forms ────────────────────────────────────────────────────
class GetJotformFormsForBusiness extends Usecase<List<JotformForm>, JotformBusinessParams> {
  final JotformRepository repository;
  GetJotformFormsForBusiness({required this.repository});
  @override
  Future<Either<Failure, List<JotformForm>>> call(JotformBusinessParams p) =>
      repository.getFormsForBusiness(p.businessId);
}

class GetJotformFormsForCredential extends Usecase<List<JotformForm>, JotformCredentialParams> {
  final JotformRepository repository;
  GetJotformFormsForCredential({required this.repository});
  @override
  Future<Either<Failure, List<JotformForm>>> call(JotformCredentialParams p) =>
      repository.getFormsForCredential(p.credentialId);
}

class SyncJotformForms extends Usecase<List<JotformForm>, JotformBusinessParams> {
  final JotformRepository repository;
  SyncJotformForms({required this.repository});
  @override
  Future<Either<Failure, List<JotformForm>>> call(JotformBusinessParams p) =>
      repository.syncForms(p.businessId);
}

class RefreshJotformQuestions extends Usecase<JotformForm, JotformFormParams> {
  final JotformRepository repository;
  RefreshJotformQuestions({required this.repository});
  @override
  Future<Either<Failure, JotformForm>> call(JotformFormParams p) =>
      repository.refreshQuestions(p.formId);
}

// ── Mapping ──────────────────────────────────────────────────
class GetSubmissionTargetFields extends Usecase<List<SubmissionField>, NoParams> {
  final JotformRepository repository;
  GetSubmissionTargetFields({required this.repository});
  @override
  Future<Either<Failure, List<SubmissionField>>> call(NoParams p) => repository.getTargetFields();
}

class GetJotformFieldMapping extends Usecase<List<FieldMappingItem>, JotformFormParams> {
  final JotformRepository repository;
  GetJotformFieldMapping({required this.repository});
  @override
  Future<Either<Failure, List<FieldMappingItem>>> call(JotformFormParams p) =>
      repository.getFieldMapping(p.formId);
}

class UpdateJotformFieldMapping extends Usecase<List<FieldMappingItem>, UpdateFieldMappingParams> {
  final JotformRepository repository;
  UpdateJotformFieldMapping({required this.repository});
  @override
  Future<Either<Failure, List<FieldMappingItem>>> call(UpdateFieldMappingParams p) =>
      repository.updateFieldMapping(formId: p.formId, mapping: p.mapping);
}

// ── Assignments ──────────────────────────────────────────────
class GetJotformAssignments extends Usecase<List<JotformAssignment>, JotformBusinessParams> {
  final JotformRepository repository;
  GetJotformAssignments({required this.repository});
  @override
  Future<Either<Failure, List<JotformAssignment>>> call(JotformBusinessParams p) =>
      repository.getAssignmentsForBusiness(p.businessId);
}

class AssignJotformForm extends Usecase<JotformAssignment, AssignFormParams> {
  final JotformRepository repository;
  AssignJotformForm({required this.repository});
  @override
  Future<Either<Failure, JotformAssignment>> call(AssignFormParams p) => repository.assignForm(
      formId: p.formId, businessMemberId: p.businessMemberId, categoryId: p.categoryId);
}
