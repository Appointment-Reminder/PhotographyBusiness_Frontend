import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/field_mapping_item.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_params.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_usecases.dart';
import '../state/jotform_accounts_state.dart';

class JotformAccountsNotifier extends StateNotifier<JotformAccountsState> {
  final int businessId;
  final GetJotformCredentials getCredentials;
  final CreateJotformCredential createCredential;
  final UpdateJotformCredential updateCredential;
  final DeleteJotformCredential deleteCredential;
  final GetJotformFormsForCredential getFormsForCredential;
  final SyncJotformForms syncForms;
  final RefreshJotformQuestions refreshQuestionsUc;
  final GetJotformFieldMapping getFieldMapping;

  JotformAccountsNotifier({
    required this.businessId,
    required this.getCredentials,
    required this.createCredential,
    required this.updateCredential,
    required this.deleteCredential,
    required this.getFormsForCredential,
    required this.syncForms,
    required this.refreshQuestionsUc,
    required this.getFieldMapping,
  }) : super(const JotformAccountsState());

  // ── Loading ────────────────────────────────────────────────
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final res = await getCredentials(JotformBusinessParams(businessId));
    final creds = res.fold((f) {
      state = state.copyWith(isLoading: false, error: f.message);
      return null;
    }, (c) => c);
    if (creds == null) return;

    state = state.copyWith(credentials: creds);
    await _reloadForms();
    state = state.copyWith(isLoading: false);
  }

  /// Reload forms of every credential, then the mapping of every form.
  Future<void> _reloadForms() async {
    final byCred = {...state.formsByCredential};
    await Future.wait(state.credentials.map((c) async {
      final r = await getFormsForCredential(JotformCredentialParams(c.id));
      r.fold((f) => state = state.copyWith(error: f.message), (list) => byCred[c.id] = list);
    }));
    state = state.copyWith(formsByCredential: byCred);
    await _reloadMappings();
  }

  Future<void> _reloadMappings() async {
    final maps = {...state.mappings};
    final ids = state.formsByCredential.values.expand((l) => l).map((f) => f.id);
    await Future.wait(ids.map((id) async {
      final r = await getFieldMapping(JotformFormParams(id));
      r.fold((_) {}, (items) => maps[id] = items);
    }));
    state = state.copyWith(mappings: maps);
  }

  // ── Credentials ────────────────────────────────────────────
  /// Creates the credential, then syncs forms from Jotform. Returns success.
  Future<bool> addCredential(String label, String apiKey) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final res = await createCredential(
        CreateCredentialParams(businessId: businessId, label: label, apiKey: apiKey));
    final cred = res.fold((f) {
      state = state.copyWith(isSubmitting: false, error: f.message);
      return null;
    }, (c) => c);
    if (cred == null) return false;

    state = state.copyWith(
      isSubmitting: false,
      credentials: [...state.credentials, cred],
      fetchingIds: {...state.fetchingIds, cred.id},
    );
    await _syncAndReload(cred.id);
    return true;
  }

  Future<bool> editCredential(int id, String label, String apiKey) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final res = await updateCredential(UpdateCredentialParams(id: id, label: label, apiKey: apiKey));
    return res.fold((f) {
      state = state.copyWith(isSubmitting: false, error: f.message);
      return false;
    }, (c) {
      state = state.copyWith(
        isSubmitting: false,
        credentials: [for (final x in state.credentials) x.id == id ? c : x],
      );
      return true;
    });
  }

  Future<void> removeCredential(int id) async {
    final res = await deleteCredential(JotformCredentialParams(id));
    res.fold((f) => state = state.copyWith(error: f.message), (_) {
      state = state.copyWith(
        credentials: state.credentials.where((c) => c.id != id).toList(),
        formsByCredential: {...state.formsByCredential}..remove(id),
      );
    });
  }

  /// "Refetch Forms". Backend sync is per business, so it refreshes all accounts.
  Future<void> refetch(int credentialId) async {
    state = state.copyWith(fetchingIds: {...state.fetchingIds, credentialId}, error: null);
    await _syncAndReload(credentialId);
  }

  Future<void> _syncAndReload(int credentialId) async {
    final r = await syncForms(JotformBusinessParams(businessId));
    r.fold((f) => state = state.copyWith(error: f.message), (_) {});
    await _reloadForms();
    state = state.copyWith(fetchingIds: {...state.fetchingIds}..remove(credentialId));
  }

  // ── Forms ──────────────────────────────────────────────────
  Future<void> refreshQuestions(int formId) async {
    final r = await refreshQuestionsUc(JotformFormParams(formId));
    r.fold((f) => state = state.copyWith(error: f.message), (updated) {
      state = state.copyWith(formsByCredential: {
        for (final e in state.formsByCredential.entries)
          e.key: [for (final f in e.value) f.id == formId ? updated : f],
      });
    });
  }

  /// Called by MappingDraftNotifier after a successful save.
  void setMapping(int formId, List<FieldMappingItem> items) =>
      state = state.copyWith(mappings: {...state.mappings, formId: items});
}
