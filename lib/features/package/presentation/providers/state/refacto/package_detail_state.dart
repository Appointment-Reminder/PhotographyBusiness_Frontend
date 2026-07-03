// package_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_price.dart';


class PackageDetailState extends Equatable {
  final Package? package;
  final PackagePrice? currentPrice;
  final bool isLoading;
  final String? error;

  const PackageDetailState({this.package, this.currentPrice, this.isLoading = false, this.error});

  PackageDetailState copyWith({
    Package? package,
    PackagePrice? currentPrice,
    bool? isLoading,
    String? error,
  }) =>
      PackageDetailState(
        package: package ?? this.package,
        currentPrice: currentPrice ?? this.currentPrice,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [package, currentPrice, isLoading, error];
}