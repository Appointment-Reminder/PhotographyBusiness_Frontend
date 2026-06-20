import 'package:equatable/equatable.dart';
import '../../../domain/entities/package.dart';
import '../../../domain/entities/package_category.dart';
import '../../../domain/entities/package_price.dart';

abstract class PackageState extends Equatable {
  const PackageState();

  @override
  List<Object?> get props => [];
}

class PackageInitial extends PackageState {
  const PackageInitial();
}

class PackageLoading extends PackageState {
  const PackageLoading();
}

class PackageListLoaded extends PackageState {
  final List<Package> packages;

  const PackageListLoaded({required this.packages});

  @override
  List<Object?> get props => [packages];
}

class PackageDetailLoaded extends PackageState {
  final Package package;
  final PackagePrice? currentPrice;

  const PackageDetailLoaded({
    required this.package,
    this.currentPrice,
  });

  @override
  List<Object?> get props => [package, currentPrice];
}

class PackageCategoryListLoaded extends PackageState {
  final List<PackageCategory> categories;

  const PackageCategoryListLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

class PackagePriceHistoryLoaded extends PackageState {
  final List<PackagePrice> prices;

  const PackagePriceHistoryLoaded({required this.prices});

  @override
  List<Object?> get props => [prices];
}

class PackageError extends PackageState {
  final String message;

  const PackageError({required this.message});

  @override
  List<Object?> get props => [message];
}
