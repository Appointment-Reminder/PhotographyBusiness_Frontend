import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_price.dart';

class PackagePriceState extends Equatable {
  final List<PackagePrice> history;
  final PackagePrice? current;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const PackagePriceState({
    this.history = const [],
    this.current,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  PackagePriceState copyWith({
    List<PackagePrice>? history,
    PackagePrice? current,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) =>
      PackagePriceState(
        history: history ?? this.history,
        current: current ?? this.current,
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  @override
  List<Object?> get props => [history, current, isLoading, isSubmitting, error];
}