import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/jotform/data/datasources/jotform_remote_datasource.dart';
import 'package:photography_business_frontend/features/jotform/data/datasources/jotform_remote_datasource_impl.dart';
import 'package:photography_business_frontend/features/jotform/data/repositories/jotform_repository_impl.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/submission_field.dart';
import 'package:photography_business_frontend/features/jotform/domain/repositories/jotform_repository.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_usecases.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';
import 'notifiers/jotform_accounts_notifier.dart';
import 'notifiers/jotform_matrix_notifier.dart';
import 'notifiers/mapping_draft_notifier.dart';
import 'state/jotform_accounts_state.dart';
import 'state/jotform_matrix_state.dart';
import 'state/mapping_draft_state.dart';

// ── Data ─────────────────────────────────────────────────────
final jotformRemoteDataSourceProvider = Provider<JotformRemoteDatasource>(
    (ref) => JotformRemoteDatasourceImpl(client: ref.read(dioProvider)));

final jotformRepositoryProvider = Provider<JotformRepository>((ref) => JotformRepositoryImpl(
      remoteDatasource: ref.read(jotformRemoteDataSourceProvider),
      networkInfo: ref.read(networkInfoProvider),
    ));

// ── Use cases ────────────────────────────────────────────────
JotformRepository _repo(Ref ref) => ref.read(jotformRepositoryProvider);

final getJotformCredentialsProvider =
    Provider((ref) => GetJotformCredentials(repository: _repo(ref)));
final createJotformCredentialProvider =
    Provider((ref) => CreateJotformCredential(repository: _repo(ref)));
final updateJotformCredentialProvider =
    Provider((ref) => UpdateJotformCredential(repository: _repo(ref)));
final deleteJotformCredentialProvider =
    Provider((ref) => DeleteJotformCredential(repository: _repo(ref)));
final getJotformFormsForBusinessProvider =
    Provider((ref) => GetJotformFormsForBusiness(repository: _repo(ref)));
final getJotformFormsForCredentialProvider =
    Provider((ref) => GetJotformFormsForCredential(repository: _repo(ref)));
final syncJotformFormsProvider = Provider((ref) => SyncJotformForms(repository: _repo(ref)));
final refreshJotformQuestionsProvider =
    Provider((ref) => RefreshJotformQuestions(repository: _repo(ref)));
final getSubmissionTargetFieldsProvider =
    Provider((ref) => GetSubmissionTargetFields(repository: _repo(ref)));
final getJotformFieldMappingProvider =
    Provider((ref) => GetJotformFieldMapping(repository: _repo(ref)));
final updateJotformFieldMappingProvider =
    Provider((ref) => UpdateJotformFieldMapping(repository: _repo(ref)));
final getJotformAssignmentsProvider =
    Provider((ref) => GetJotformAssignments(repository: _repo(ref)));
final assignJotformFormProvider = Provider((ref) => AssignJotformForm(repository: _repo(ref)));

// ── Target fields (static, cached for the app session) ───────
final targetFieldsProvider = FutureProvider<List<SubmissionField>>((ref) async {
  final res = await ref.read(getSubmissionTargetFieldsProvider)(NoParams());
  return res.fold((f) => throw Exception(f.message), (fields) => fields);
});

// ── Integration page: accounts + forms ───────────────────────
final jotformAccountsProvider =
    StateNotifierProvider.family<JotformAccountsNotifier, JotformAccountsState, int>((ref, businessId) {
  final n = JotformAccountsNotifier(
    businessId: businessId,
    getCredentials: ref.read(getJotformCredentialsProvider),
    createCredential: ref.read(createJotformCredentialProvider),
    updateCredential: ref.read(updateJotformCredentialProvider),
    deleteCredential: ref.read(deleteJotformCredentialProvider),
    getFormsForCredential: ref.read(getJotformFormsForCredentialProvider),
    syncForms: ref.read(syncJotformFormsProvider),
    refreshQuestionsUc: ref.read(refreshJotformQuestionsProvider),
    getFieldMapping: ref.read(getJotformFieldMappingProvider),
  );
  n.load();
  return n;
});

// ── Mapping panel draft (one per open form) ──────────────────
final mappingDraftProvider = StateNotifierProvider.autoDispose
    .family<MappingDraftNotifier, MappingDraftState, MappingKey>((ref, key) {
  final accounts = ref.read(jotformAccountsProvider(key.businessId).notifier);
  return MappingDraftNotifier(
    formId: key.formId,
    initial: ref.read(jotformAccountsProvider(key.businessId)).mappingFor(key.formId),
    updateMapping: ref.read(updateJotformFieldMappingProvider),
    onSaved: (saved) => accounts.setMapping(key.formId, saved),
  );
});

// ── Matrix (member x category -> form) ───────────────────────
final jotformMatrixNotifierProvider =
    StateNotifierProvider<JotformMatrixNotifier, JotformMatrixState>((ref) {
  return JotformMatrixNotifier(
    getCategories: ref.read(getPackageCategoriesForBusinessProvider),
    getForms: ref.read(getJotformFormsForBusinessProvider),
    getAssignments: ref.read(getJotformAssignmentsProvider),
    assignForm: ref.read(assignJotformFormProvider),
  );
});
