import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/field_mapping_item.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_params.dart';
import 'package:photography_business_frontend/features/jotform/domain/usecases/jotform_usecases.dart';
import '../../../domain/entities/question_selection.dart';
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

  void reset() =>
      state = MappingDraftState(draft: groupMapping(state.original), original: state.original);

  void setQuestions(String targetKey, List<QuestionSelection> selections) =>
      state = state.copyWith(draft: {...state.draft, targetKey: selections}, saved: false);

  Future<void> save() async {
    state = state.copyWith(isSaving: true, error: null);
    final items = [
      for (final e in state.draft.entries)
        for (var i = 0; i < e.value.length; i++)
          FieldMappingItem(targetKey: e.key, qid: e.value[i].qid, priority: i, subkey: e.value[i].subkey),
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
