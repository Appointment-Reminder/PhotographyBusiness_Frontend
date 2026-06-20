import 'package:equatable/equatable.dart';

class PackageCategory extends Equatable {
  final int id;
  final String name;
  final int businessId;

  const PackageCategory({
    required this.id,
    required this.name,
    required this.businessId,
  });

  @override
  List<Object?> get props => [id, name, businessId];
}
