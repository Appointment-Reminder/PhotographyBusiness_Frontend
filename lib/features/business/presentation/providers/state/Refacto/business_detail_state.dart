// business_detail_state.dart
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';

class BusinessDetailState extends Equatable {
  final Business? business;
  final bool isLoading;
  final String? error;

  const BusinessDetailState({this.business, this.isLoading = false, this.error});

  BusinessDetailState copyWith({Business? business, bool? isLoading, String? error}) =>
      BusinessDetailState(
        business: business ?? this.business,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [business, isLoading, error];
}