abstract class BusinessState {}
class BusinessInitial extends BusinessState {}
class BusinessLoading extends BusinessState {}
class BusinessListLoaded extends BusinessState {
  final List<Business> businesses;
}
class BusinessDetailLoaded extends BusinessState{
  final business business;
}
class BusinessError extends BusinessState{
  final String message;
}
