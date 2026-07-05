// member_commission_state.dart — replaces business_member_commission_state.dart
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';


class MemberCommissionState extends Equatable {
  final MemberCommission? commission;
  final bool isLoading;
  final String? error;

  const MemberCommissionState({this.commission, this.isLoading = false, this.error});

  MemberCommissionState copyWith({MemberCommission? commission, bool? isLoading, String? error}) =>
      MemberCommissionState(
        commission: commission ?? this.commission,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [commission, isLoading, error];
}