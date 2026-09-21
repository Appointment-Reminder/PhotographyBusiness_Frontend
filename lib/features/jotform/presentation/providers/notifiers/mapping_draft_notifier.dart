import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/field_mapping_item.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_params.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_usecases.dart';
import '../mapping_utils.dart';
import '../state/mapping_draft_state.dart';

class MappingDraftNotifier extends StateNotifier<MappingDraftState> {
  final int formId;
  final UpdateJotformFieldMapping updateMapping;
  final void Function(List<FieldMappingItem> saved) onSaved;

  MappingDraftNotifier({
    required this.formId,
    required List<FieldMappingItem> initial,
    required this.updateMapping,
    required this.onSaved,
  }) : super(MappingDraftState(draft: groupMapping(initial), original: initial));

  void setQuestions(String targetKey, List<String> qids) =>
      state = state.copyWith(draft: {...state.draft, targetKey: qids}, original: state.original, saved: false);

  void reset() =>
      state = MappingDraftState(draft: groupMapping(state.original), original: state.original);

  Future<void> save() async {
    state = state.copyWith(isSaving: true, error: null);

    String? subkeyOf(String key, String qid) => state.original
        .where((o) => o.targetKey == key && o.qid == qid)
        .map((o) => o.subkey)
        .firstOrNull;

    final items = [
      for (final e in state.draft.entries)
        for (var i = 0; i < e.value.length; i++)
          FieldMappingItem(
              targetKey: e.key, qid: e.value[i], priority: i, subkey: subkeyOf(e.key, e.value[i])),
    ];

    final res = await updateMapping(UpdateFieldMappingParams(formId: formId, mapping: items));
    res.fold(
      (f) => state = state.copyWith(isSaving: false, error: f.message),
      (saved) {
        onSaved(saved);
        state = MappingDraftState(draft: groupMapping(saved), original: saved, saved: true);
      },
    );
  }
}
