import 'package:equatable/equatable.dart';

class Business extends Equatable{
  final int id;
  final String name;
  final String? description;
  final int ownerId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Business({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });



  @override
  List<Object?> get props => [
    id,
    name,
    description,
    ownerId,
    isActive,
    createdAt,
    updatedAt
  ];

}