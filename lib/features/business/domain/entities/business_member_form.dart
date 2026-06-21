
import 'package:equatable/equatable.dart';

class BusinessMemberForm extends Equatable {
  final int id;
  final int businessMemberId;
  final int categoryId;
  final String webhookToken;
  final String jotformFieldMap;
  final DateTime createdAt;

  const BusinessMemberForm(
      {
        required this.id,
        required this.businessMemberId,
        required this.categoryId,
        required this.webhookToken,
        required this.jotformFieldMap,
        required this.createdAt
      });


  @override
  // TODO: implement props
  List<Object?> get props => [id, businessMemberId, categoryId, webhookToken, jotformFieldMap, createdAt];
}