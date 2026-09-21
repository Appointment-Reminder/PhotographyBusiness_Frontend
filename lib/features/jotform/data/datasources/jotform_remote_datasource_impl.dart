import 'package:dio/dio.dart';
import '../../domain/entities/field_mapping_item.dart';
import '../../domain/entities/jotform_assignment.dart';
import '../../domain/entities/jotform_credential.dart';
import '../../domain/entities/jotform_form.dart';
import '../../domain/entities/submission_field.dart';
import '../models/field_mapping_item_model.dart';
import '../models/jotform_assignment_model.dart';
import '../models/jotform_credential_model.dart';
import '../models/jotform_form_model.dart';
import '../models/submission_field_model.dart';
import 'jotform_remote_datasource.dart';

class JotformRemoteDatasourceImpl implements JotformRemoteDatasource {
  final Dio client;
  JotformRemoteDatasourceImpl({required this.client});

  static const _base = '/webhooks/jotform';

  List<T> _list<T>(dynamic data, T Function(Map<String, dynamic>) f) =>
      (data as List).map((e) => f(Map<String, dynamic>.from(e as Map))).toList();

  // ── Credentials ──
  @override
  Future<List<JotformCredential>> getCredentials(int businessId) async {
    final r = await client.get('$_base/business/$businessId/jotform/credentials');
    return _list(r.data, JotformCredentialModel.fromJson);
  }

  @override
  Future<JotformCredential> createCredential(
      {required int businessId, required String label, required String apiKey}) async {
    final r = await client.post('$_base/jotform/credentials',
        data: {'business_id': businessId, 'label': label, 'api_key': apiKey});
    return JotformCredentialModel.fromJson(r.data);
  }

  @override
  Future<JotformCredential> updateCredential(
      {required int id, required String label, required String apiKey}) async {
    final r = await client.patch('$_base/jotform/credentials',
        data: {'id': id, 'label': label, 'api_key': apiKey});
    return JotformCredentialModel.fromJson(r.data);
  }

  @override
  Future<void> deleteCredential(int credentialId) async {
    await client.delete('$_base/jotform/credentials/$credentialId');
  }

  // ── Forms ──
  @override
  Future<List<JotformForm>> getFormsForBusiness(int businessId) async {
    final r = await client.get('$_base/business/$businessId/jotform/form');
    return _list(r.data, JotformFormModel.fromJson);
  }

  @override
  Future<List<JotformForm>> getFormsForCredential(int credentialId) async {
    final r = await client.get('$_base/jotform/credentials/$credentialId/forms');
    return _list(r.data, JotformFormModel.fromJson);
  }

  @override
  Future<List<JotformForm>> syncForms(int businessId) async {
    // NOTE: backend path is missing a slash ("jotformbusiness"). Fix here when backend is fixed.
    final r = await client.post('/webhooks/jotformbusiness/$businessId/jotform/forms/update');
    return _list(r.data, JotformFormModel.fromJson);
  }

  @override
  Future<JotformForm> refreshQuestions(int formId) async {
    final r = await client.post('$_base/jotform/form/$formId/questions/refresh');
    return JotformFormModel.fromJson(r.data);
  }

  // ── Mapping ──
  @override
  Future<List<SubmissionField>> getTargetFields() async {
    final r = await client.get('$_base/jotform/target-fields');
    return _list(r.data, SubmissionFieldModel.fromJson);
  }

  @override
  Future<List<FieldMappingItem>> getFieldMapping(int formId) async {
    final r = await client.get('$_base/jotform/form/$formId/mapping');
    return _list(r.data, FieldMappingItemModel.fromJson);
  }

  @override
  Future<List<FieldMappingItem>> updateFieldMapping(
      {required int formId, required List<FieldMappingItem> mapping}) async {
    final r = await client.put('$_base/jotform/form/$formId/mapping', data: {
      'mapping': mapping.map((m) => FieldMappingItemModel.fromEntity(m).toJson()).toList(),
    });
    return _list(r.data, FieldMappingItemModel.fromJson);
  }

  // ── Assignments ──
  @override
  Future<List<JotformAssignment>> getAssignmentsForBusiness(int businessId) async {
    // ASSUMED endpoint — adjust to the final backend path.
    final r = await client.get('$_base/jotform/$businessId/form/assign');
    return _list(r.data, JotformAssignmentModel.fromJson);
  }

  @override
  Future<JotformAssignment> assignForm(
      {required int formId, required int businessMemberId, required int categoryId}) async {
    final r = await client.post('$_base/jotform/form/assign', data: {
      'form_id': formId,
      'business_member_id': businessMemberId,
      'category_id': categoryId,
    });
    return JotformAssignmentModel.fromJson(r.data);
  }
}
