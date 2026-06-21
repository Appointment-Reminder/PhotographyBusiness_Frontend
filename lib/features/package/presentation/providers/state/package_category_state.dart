import 'package:equatable/equatable.dart';
import '../../../domain/entities/package_category.dart';

abstract class PackageCategoryState extends Equatable {
  const PackageCategoryState();

  @override
  List<Object?> get props => [];
}

class PackageCategoryInitial extends PackageCategoryState{
  const PackageCategoryInitial();
}

class PackageCategoryLoading extends PackageCategoryState{
  const PackageCategoryLoading();
}

class PackageCategoryListLoaded extends PackageCategoryState{
  final List<PackageCategory> categories;

  const PackageCategoryListLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class PackageCategoryError extends PackageCategoryState {
  final String message;

  const PackageCategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}