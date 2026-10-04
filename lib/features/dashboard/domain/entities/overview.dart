import 'package:equatable/equatable.dart';

/// Business-wide headline figures. Absent for a photographer.
class BusinessFigures extends Equatable {
  final double totalIncome;
  final double bookedRevenue;
  final int appointmentsMade;
  final double commissionPayable;
  final int unresolvedAddons;
  final int commissionsAboveBalance;

  const BusinessFigures({
    required this.totalIncome,
    required this.bookedRevenue,
    required this.appointmentsMade,
    required this.commissionPayable,
    required this.unresolvedAddons,
    required this.commissionsAboveBalance,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        bookedRevenue,
        appointmentsMade,
        commissionPayable,
        unresolvedAddons,
        commissionsAboveBalance,
      ];
}

class MemberRow extends Equatable {
  final String name;
  final double income;
  final double bookedRevenue;
  final int appointmentsMade;
  final double commissionEarned;

  const MemberRow({
    required this.name,
    required this.income,
    required this.bookedRevenue,
    required this.appointmentsMade,
    required this.commissionEarned,
  });

  @override
  List<Object?> get props => [name, income, bookedRevenue, appointmentsMade, commissionEarned];
}

/// The previous period and the change versus it; a null percent means the
/// previous figure was zero.
class Comparison extends Equatable {
  final DateTime previousFrom;
  final DateTime previousTo;
  final double? totalIncomeChange;
  final double? bookedRevenueChange;
  final double? appointmentsMadeChange;
  final double? commissionPayableChange;

  const Comparison({
    required this.previousFrom,
    required this.previousTo,
    this.totalIncomeChange,
    this.bookedRevenueChange,
    this.appointmentsMadeChange,
    this.commissionPayableChange,
  });

  @override
  List<Object?> get props => [
        previousFrom,
        previousTo,
        totalIncomeChange,
        bookedRevenueChange,
        appointmentsMadeChange,
        commissionPayableChange,
      ];
}

class SeriesPoint extends Equatable {
  final DateTime start;
  final double depositIncome;
  final double balanceIncome;

  const SeriesPoint({required this.start, required this.depositIncome, required this.balanceIncome});

  @override
  List<Object?> get props => [start, depositIncome, balanceIncome];
}

class Overview extends Equatable {
  final BusinessFigures? business;
  final List<MemberRow> members;
  final Comparison? comparison;
  final List<SeriesPoint>? series;

  const Overview({this.business, this.members = const [], this.comparison, this.series});

  @override
  List<Object?> get props => [business, members, comparison, series];
}
