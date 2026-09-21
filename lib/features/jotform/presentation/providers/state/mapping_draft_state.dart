import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/field_mapping_item.dart';

class MappingKey extends Equatable {
  final int businessId;
  final int formId;
  const MappingKey(this.businessId, this.formId);
  @override
  List<Object?> get props => [businessId, formId];
}

class MappingDraftState extends Equatable {
  final Map<String, List<String>> draft;      // targetKey -> ordered qids
  final List<FieldMappingItem> original;      // kept to preserve subkeys
  final bool isSaving;
  final bool saved;
  final String? error;

  const MappingDraftState({
    this.draft = const {},
    this.original = const [],
    this.isSaving = false,
    this.saved = false,
    this.error,
  });

  MappingDraftState copyWith({
    Map<String, List<String>>? draft,
    List<FieldMappingItem>? original,
    bool? isSaving,
    bool? saved,
    String? error,
  }) =>
      MappingDraftState(
        draft: draft ?? this.draft,
        original: original ?? this.original,
        isSaving: isSaving ?? this.isSaving,
        saved: saved ?? this.saved,
        error: error,
      );

  @override
  List<Object?> get props => [draft, original, isSaving, saved, error];
}
