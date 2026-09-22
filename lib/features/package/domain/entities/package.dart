import 'package:equatable/equatable.dart';

class Package extends Equatable {
  final int id;
  final int businessId;
  final int categoryId;
  final String name;
  final String description;
  final bool isActive;
  final String? jotformAlias;

  const Package({
    required this.id,
    required this.businessId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.isActive,
    this.jotformAlias,
  });

  @override
  List<Object?> get props => [id, businessId, categoryId, name, description, isActive, jotformAlias];
}
