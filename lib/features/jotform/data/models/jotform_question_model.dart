import '../../domain/entities/jotform_question.dart';

class JotformQuestionModel extends JotformQuestion {
  const JotformQuestionModel({required super.id, required super.name, super.options});

  factory JotformQuestionModel.fromJson(Map<String, dynamic> json) => JotformQuestionModel(
        id: json['id'].toString(),
        name: json['name'],
        options: (json['options'] as List? ?? const []).map((e) => e.toString()).toList(),
      );
}
