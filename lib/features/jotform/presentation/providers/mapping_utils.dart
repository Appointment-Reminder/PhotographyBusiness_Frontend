import 'package:photography_business_frontend/features/jotform/domain/entities/field_mapping_item.dart';
import 'package:photography_business_frontend/features/jotform/domain/entities/submission_field.dart';

/// API items -> UI model (targetKey -> ordered qids)
Map<String, List<String>> groupMapping(List<FieldMappingItem> items) {
  final sorted = [...items]..sort((a, b) => a.priority.compareTo(b.priority));
  final out = <String, List<String>>{};
  for (final i in sorted) {
    (out[i.targetKey] ??= []).add(i.qid);
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

MappingProgress computeProgress(Map<String, List<String>> mapping, List<SubmissionField> fields) {
  bool has(String k) => (mapping[k] ?? const []).isNotEmpty;
  return MappingProgress(
    fields.where((f) => has(f.key)).length,
    fields.length,
    fields.where((f) => f.required && !has(f.key)).length,
  );
}
