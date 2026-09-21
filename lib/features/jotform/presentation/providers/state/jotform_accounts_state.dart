import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/field_mapping_item.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_credential.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/jotform_form.dart';

const _keep = Object();

class JotformAccountsState extends Equatable {
  final List<JotformCredential> credentials;
  final Map<int, List<JotformForm>> formsByCredential; // credentialId -> forms
  final Map<int, List<FieldMappingItem>> mappings;     // formId -> saved mapping
  final Set<int> fetchingIds;                          // credentialIds being refetched
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const JotformAccountsState({
    this.credentials = const [],
    this.formsByCredential = const {},
    this.mappings = const {},
    this.fetchingIds = const {},
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  List<JotformForm> formsFor(int credentialId) => formsByCredential[credentialId] ?? const [];
  List<FieldMappingItem> mappingFor(int formId) => mappings[formId] ?? const [];

  /// error: omit to keep, pass null to clear.
  JotformAccountsState copyWith({
    List<JotformCredential>? credentials,
    Map<int, List<JotformForm>>? formsByCredential,
    Map<int, List<FieldMappingItem>>? mappings,
    Set<int>? fetchingIds,
    bool? isLoading,
    bool? isSubmitting,
    Object? error = _keep,
  }) =>
      JotformAccountsState(
        credentials: credentials ?? this.credentials,
        formsByCredential: formsByCredential ?? this.formsByCredential,
        mappings: mappings ?? this.mappings,
        fetchingIds: fetchingIds ?? this.fetchingIds,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: identical(error, _keep) ? this.error : error as String?,
      );

  @override
  List<Object?> get props =>
      [credentials, formsByCredential, mappings, fetchingIds, isLoading, isSubmitting, error];
}
