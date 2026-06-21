import 'package:equatable/equatable.dart';
import '../../../domain/entities/package_price.dart';

abstract class PackagePriceState extends Equatable {
  const PackagePriceState();

  @override
  List<Object?> get props => [];
}

class PackagePriceInitial extends PackagePriceState {
  const PackagePriceInitial();
}

class PackagePriceLoading extends PackagePriceState {
  const PackagePriceLoading();
}

class PackagePriceHistoryLoaded extends PackagePriceState {
  final List<PackagePrice> prices;

  const PackagePriceHistoryLoaded({required this.prices});

  @override
  List<Object?> get props => [prices];
}

class PackagePriceCreated extends PackagePriceState {
  final PackagePrice price;

  const PackagePriceCreated({required this.price});

  @override
  List<Object?> get props => [price];
}

class PackagePriceError extends PackagePriceState {
  final String message;

  const PackagePriceError({required this.message});

  @override
  List<Object?> get props => [message];
}