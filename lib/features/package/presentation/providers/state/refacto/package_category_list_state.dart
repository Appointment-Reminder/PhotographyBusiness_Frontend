// package_category_list_state.dart — replaces PackageCategoryState union
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';

class PackageCategoryListState extends Equatable {
  final List<PackageCategory> categories;
  final bool isLoading;
  final String? error;

  const PackageCategoryListState({this.categories = const [], this.isLoading = false, this.error});

  PackageCategoryListState copyWith({List<PackageCategory>? categories, bool? isLoading, String? error}) =>
      PackageCategoryListState(
        categories: categories ?? this.categories,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [categories, isLoading, error];
}