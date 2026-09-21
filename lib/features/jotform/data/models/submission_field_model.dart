import '../../domain/entities/submission_field.dart';

class SubmissionFieldModel extends SubmissionField {
  const SubmissionFieldModel({
    required super.key,
    required super.label,
    required super.type,
    required super.required,
  });

  factory SubmissionFieldModel.fromJson(Map<String, dynamic> json) => SubmissionFieldModel(
        key: json['key'],
        label: json['label'],
        type: (json['type'] as String).toUpperCase(),
        required: json['required'],
      );
}
