import 'package:equatable/equatable.dart';
import '../../../domain/entities/member_commission.dart';

abstract class MemberCommissionState extends Equatable {
  const MemberCommissionState();
  @override
  List<Object?> get props => [];
}

class MemberCommissionInitial extends MemberCommissionState {
  const MemberCommissionInitial();
}

class MemberCommissionLoading extends MemberCommissionState {
  const MemberCommissionLoading();
}

class MemberCommissionLoaded extends MemberCommissionState {
  final MemberCommission commission;
  const MemberCommissionLoaded({required this.commission});
  @override
  List<Object?> get props => [commission];
}

class MemberCommissionError extends MemberCommissionState {
  final String message;
  const MemberCommissionError({required this.message});
  @override
  List<Object?> get props => [message];
}