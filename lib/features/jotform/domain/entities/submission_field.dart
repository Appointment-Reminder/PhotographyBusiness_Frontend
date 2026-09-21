import 'package:equatable/equatable.dart';

class SubmissionField extends Equatable {
  final String key;
  final String label;
  final String type; // DATE, TEXT, BOOL, LIST, NUMBER
  final bool required;

  const SubmissionField({
    required this.key,
    required this.label,
    required this.type,
    required this.required,
  });

  @override
  List<Object?> get props => [key, label, type, required];
}
