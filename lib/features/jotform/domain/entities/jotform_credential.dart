import 'package:equatable/equatable.dart';

class JotformCredential extends Equatable {
  final int id;
  final int businessId;
  final String label;
  final String apiKey;
  final DateTime createdAt;

  const JotformCredential({
    required this.id,
    required this.businessId,
    required this.label,
    required this.apiKey,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, businessId, label, apiKey, createdAt];
}
