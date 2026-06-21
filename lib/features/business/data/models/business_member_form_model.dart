import '../../domain/entities/business_member_form.dart';

class BusinessMemberFormModel extends BusinessMemberForm {
  const BusinessMemberFormModel({
    required super.id,
    required super.businessMemberId,
    required super.categoryId,
    required super.webhookToken,
    required super.jotformFieldMap,
    required super.createdAt,
  });

  factory BusinessMemberFormModel.fromJson(Map<String, dynamic> json) {
    return BusinessMemberFormModel(
      id: json['id'],
      businessMemberId: json['business_member_id'],
      categoryId: json['category_id'],
      webhookToken: json['webhook_token'],
      jotformFieldMap: json['jotform_field_map'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'business_member_id': businessMemberId,
      'category_id': categoryId,
      'jotform_field_map': jotformFieldMap,
    };
  }
}