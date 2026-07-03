// package_list_state.dart
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';

class PackageListState extends Equatable {
  final List<Package> packages;
  final bool isLoading;
  final String? error;

  const PackageListState({this.packages = const [], this.isLoading = false, this.error});

  PackageListState copyWith({List<Package>? packages, bool? isLoading, String? error}) =>
      PackageListState(
        packages: packages ?? this.packages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [packages, isLoading, error];
}