import 'package:equatable/equatable.dart';

class JotformAssignment extends Equatable {
  final int id;
  final int formId;           // internal JotformForm.id
  final int businessMemberId;
  final int categoryId;

  const JotformAssignment({
    required this.id,
    required this.formId,
    required this.businessMemberId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [id, formId, businessMemberId, categoryId];
}
