import '../../domain/entities/field_mapping_item.dart';
import '../../domain/entities/jotform_assignment.dart';
import '../../domain/entities/jotform_credential.dart';
import '../../domain/entities/jotform_form.dart';
import '../../domain/entities/submission_field.dart';

abstract class JotformRemoteDatasource {
  Future<List<JotformCredential>> getCredentials(int businessId);
  Future<JotformCredential> createCredential({required int businessId, required String label, required String apiKey});
  Future<JotformCredential> updateCredential({required int id, required String label, required String apiKey});
  Future<void> deleteCredential(int credentialId);

  Future<List<JotformForm>> getFormsForBusiness(int businessId);
  Future<List<JotformForm>> getFormsForCredential(int credentialId);
  Future<List<JotformForm>> syncForms(int businessId);
  Future<JotformForm> refreshQuestions(int formId);

  Future<List<SubmissionField>> getTargetFields();
  Future<List<FieldMappingItem>> getFieldMapping(int formId);
  Future<List<FieldMappingItem>> updateFieldMapping({required int formId, required List<FieldMappingItem> mapping});

  Future<List<JotformAssignment>> getAssignmentsForBusiness(int businessId);
  Future<JotformAssignment> assignForm({required int formId, required int businessMemberId, required int categoryId});
}
