import '../../domain/entities/jotform_form.dart';
import 'jotform_question_model.dart';

class JotformFormModel extends JotformForm {
  const JotformFormModel({
    required super.id,
    required super.formId,
    required super.name,
    required super.webhookToken,
    required super.questions,
    required super.createdAt,
    super.fieldMapping,
  });

  factory JotformFormModel.fromJson(Map<String, dynamic> json) => JotformFormModel(
        id: json['id'],
        formId: json['form_id'].toString(),
        name: json['name'],
        webhookToken: json['webhook_token'],
        fieldMapping: (json['field_mapping'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
        questions: (json['questions'] as List? ?? const [])
            .map((q) => JotformQuestionModel.fromJson(Map<String, dynamic>.from(q as Map)))
            .toList(),
        createdAt: DateTime.parse(json['created_at']),
      );
}
