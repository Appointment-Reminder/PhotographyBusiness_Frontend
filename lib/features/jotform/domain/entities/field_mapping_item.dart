import 'package:equatable/equatable.dart';

/// One (targetKey <- qid) link. Several items with the same targetKey
/// form the ordered question list shown in the UI (order = priority).
class FieldMappingItem extends Equatable {
  final String targetKey;
  final String qid;
  final int priority;
  final String? subkey;

  const FieldMappingItem({
    required this.targetKey,
    required this.qid,
    required this.priority,
    this.subkey,
  });

  @override
  List<Object?> get props => [targetKey, qid, priority, subkey];
}
