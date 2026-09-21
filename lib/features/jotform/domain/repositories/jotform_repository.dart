import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/field_mapping_item.dart';
import '../entities/jotform_assignment.dart';
import '../entities/jotform_credential.dart';
import '../entities/jotform_form.dart';
import '../entities/submission_field.dart';

abstract class JotformRepository {
  // Credentials
  Future<Either<Failure, List<JotformCredential>>> getCredentials(int businessId);
  Future<Either<Failure, JotformCredential>> createCredential({
    required int businessId,
    required String label,
    required String apiKey,
  });
  Future<Either<Failure, JotformCredential>> updateCredential({
    required int id,
    required String label,
    required String apiKey,
  });
  Future<Either<Failure, void>> deleteCredential(int credentialId);

  // Forms
  Future<Either<Failure, List<JotformForm>>> getFormsForBusiness(int businessId);
  Future<Either<Failure, List<JotformForm>>> getFormsForCredential(int credentialId);
  Future<Either<Failure, List<JotformForm>>> syncForms(int businessId);
  Future<Either<Failure, JotformForm>> refreshQuestions(int formId);

  // Mapping
  Future<Either<Failure, List<SubmissionField>>> getTargetFields();
  Future<Either<Failure, List<FieldMappingItem>>> getFieldMapping(int formId);
  Future<Either<Failure, List<FieldMappingItem>>> updateFieldMapping({
    required int formId,
    required List<FieldMappingItem> mapping,
  });

  // Assignments (member x category -> form)
  Future<Either<Failure, List<JotformAssignment>>> getAssignmentsForBusiness(int businessId);
  Future<Either<Failure, JotformAssignment>> assignForm({
    required int formId,
    required int businessMemberId,
    required int categoryId,
  });
}
