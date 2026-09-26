import 'package:photography_business_frontend/features/jotform/domain/entities/field_mapping_item.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/question_selection.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/submission_field.dart';

/// API items -> UI model (targetKey -> ordered selections, each carrying its subkey)
Map<String, List<QuestionSelection>> groupMapping(List<FieldMappingItem> items) {
  final sorted = [...items]..sort((a, b) => a.priority.compareTo(b.priority));
  final out = <String, List<QuestionSelection>>{};
  for (final i in sorted) {
    (out[i.targetKey] ??= []).add(QuestionSelection(i.qid, subkey: i.subkey));
  }
  return out;
}

class MappingProgress {
  final int mapped;
  final int total;
  final int requiredMissing;
  const MappingProgress(this.mapped, this.total, this.requiredMissing);

  bool get isComplete => requiredMissing == 0;
  bool get isPartial => mapped > 0 && !isComplete;
}

MappingProgress computeProgress(
    Map<String, List<QuestionSelection>> mapping, List<SubmissionField> fields) {
  bool has(String k) => (mapping[k] ?? const []).isNotEmpty;
  return MappingProgress(
    fields.where((f) => has(f.key)).length,
    fields.length,
    fields.where((f) => f.required && !has(f.key)).length,
  );
}