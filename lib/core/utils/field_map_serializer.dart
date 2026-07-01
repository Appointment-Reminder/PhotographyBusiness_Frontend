import 'dart:convert';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/webhook_config_panel.dart';

class FieldMapSerializer {
  /// List<FieldMapping> → JSON string for API
  static String serialize(List<FieldMapping> mappings) {
    return jsonEncode(
      mappings
          .map((m) => {'from': m.jotformField, 'to': m.targetField})
          .toList(),
    );
  }

  /// JSON string from API → List<FieldMapping>
  static List<FieldMapping> deserialize(String raw) {
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((m) => FieldMapping(
        jotformField: m['from'] as String,
        targetField: m['to'] as String,
      ))
          .toList();
    } catch (_) {
      return [];
    }
  }
}