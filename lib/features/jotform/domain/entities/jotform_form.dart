import 'package:equatable/equatable.dart';
import 'jotform_question.dart';

class JotformForm extends Equatable {
  final int id;               // internal id (used by API paths)
  final String formId;        // Jotform's own id
  final String name;
  final String webhookToken;
  final List<Map<String, dynamic>>? fieldMapping; // raw, shape unconfirmed
  final List<JotformQuestion> questions;
  final DateTime createdAt;

  const JotformForm({
    required this.id,
    required this.formId,
    required this.name,
    required this.webhookToken,
    required this.questions,
    required this.createdAt,
    this.fieldMapping,
  });

  @override
  List<Object?> get props => [id, formId, name, webhookToken, fieldMapping, questions, createdAt];
}
