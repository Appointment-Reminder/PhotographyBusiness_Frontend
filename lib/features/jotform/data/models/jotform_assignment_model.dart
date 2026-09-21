import '../../domain/entities/jotform_assignment.dart';

class JotformAssignmentModel extends JotformAssignment {
  const JotformAssignmentModel({
    required super.id,
    required super.formId,
    required super.businessMemberId,
    required super.categoryId,
  });

  factory JotformAssignmentModel.fromJson(Map<String, dynamic> json) => JotformAssignmentModel(
        id: json['id'],
        formId: json['form_id'],
        businessMemberId: json['business_member_id'],
        categoryId: json['category_id'],
      );
}
