import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';

class BusinessListState extends Equatable {
  final List<Business> businesses;
  final bool isLoading;
  final String? error;

  const BusinessListState({ this.businesses = const [], this.isLoading = false, this.error});

  BusinessListState copyWith({
    List<Business>? businesses,
    bool? isLoading,
    String? error,
  }) => BusinessListState(
    businesses: businesses ?? this.businesses,
    isLoading: isLoading ?? this.isLoading,
    error: error, // explicit: pass null to clear it
  );


  @override
  List<Object?> get props => [businesses, isLoading, error];

}