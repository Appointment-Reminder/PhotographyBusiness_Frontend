import '../../domain/entities/jotform_credential.dart';

class JotformCredentialModel extends JotformCredential {
  const JotformCredentialModel({
    required super.id,
    required super.businessId,
    required super.label,
    required super.apiKey,
    required super.createdAt,
  });

  factory JotformCredentialModel.fromJson(Map<String, dynamic> json) => JotformCredentialModel(
        id: json['id'],
        businessId: json['business_id'],
        label: json['label'],
        apiKey: json['api_key'],
        createdAt: DateTime.parse(json['created_at']),
      );
}
