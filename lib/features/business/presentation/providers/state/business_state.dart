import '../../../domain/entities/business.dart';

abstract class BusinessState {
  const BusinessState();
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
}
class BusinessDetailLoaded extends BusinessState{
  final Business business;

  const BusinessDetailLoaded({required this.business});
}
class BusinessError extends BusinessState{
  final String message;

  const BusinessError({required this.message});
}
