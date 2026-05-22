import 'package:equatable/equatable.dart';

import '../../../domain/entities/business.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object?> get props => [];

}
class BusinessInitial extends BusinessState {
  const BusinessInitial();
}
class BusinessLoading extends BusinessState {
  const BusinessLoading();
}
class BusinessListLoaded extends BusinessState {
  final List<Business> businesses;

  const BusinessListLoaded({required this.businesses});

  @override
  List<Object?> get props => [businesses];
}
class BusinessDetailLoaded extends BusinessState{
  final Business business;

  const BusinessDetailLoaded({required this.business});

  @override
  List<Object?> get props => [business];
}
class BusinessError extends BusinessState{
  final String message;

  const BusinessError({required this.message});

  @override
  List<Object?> get props => [message];
}
