import '../../domain/entities/field_mapping_item.dart';

class FieldMappingItemModel extends FieldMappingItem {
  const FieldMappingItemModel({
    required super.targetKey,
    required super.qid,
    required super.priority,
    super.subkey,
  });

  factory FieldMappingItemModel.fromEntity(FieldMappingItem e) => FieldMappingItemModel(
        targetKey: e.targetKey, qid: e.qid, priority: e.priority, subkey: e.subkey);

  factory FieldMappingItemModel.fromJson(Map<String, dynamic> json) => FieldMappingItemModel(
        targetKey: json['target_key'],
        qid: json['qid'].toString(),
        priority: json['priority'],
        subkey: json['subkey'],
      );

  Map<String, dynamic> toJson() => {
        'target_key': targetKey,
        'qid': qid,
        'priority': priority,
        if (subkey != null) 'subkey': subkey,
      };
}
