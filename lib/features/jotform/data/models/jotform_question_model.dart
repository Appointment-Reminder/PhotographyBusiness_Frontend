import '../../domain/entities/jotform_question.dart';

class JotformQuestionModel extends JotformQuestion {
  const JotformQuestionModel({required super.id, required super.name, super.options, super.subkeys});

  factory JotformQuestionModel.fromJson(Map<String, dynamic> json) => JotformQuestionModel(
    id: json['id'].toString(),
    name: json['name'],
    options: (json['options'] as List? ?? const []).map((e) => e.toString()).toList(),
    subkeys: (json['subkeys'] as List? ?? const []).map((e) => e.toString()).toList(),
  );
}
