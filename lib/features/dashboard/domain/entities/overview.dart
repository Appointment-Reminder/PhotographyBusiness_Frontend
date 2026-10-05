import 'package:equatable/equatable.dart';

/// Business-wide headline figures. Absent for a photographer.
class BusinessFigures extends Equatable {
  final double totalIncome;
  final double depositIncome;

  /// The balance paid on the Package (the shooting session).
  final double packageBalance;
  final double addonIncome;
  final double bookedRevenue;
  final int appointmentsMade;
  final double commissionPayable;

  /// Owner only: null for an admin.
  final double? ownerTake;
  final double averageAppointmentValue;
  final int unresolvedAddons;
  final int commissionsAboveBalance;

  const BusinessFigures({
    required this.totalIncome,
    this.depositIncome = 0,
    this.packageBalance = 0,
    this.addonIncome = 0,
    required this.bookedRevenue,
    required this.appointmentsMade,
    required this.commissionPayable,
    this.ownerTake,
    this.averageAppointmentValue = 0,
    required this.unresolvedAddons,
    required this.commissionsAboveBalance,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        depositIncome,
        packageBalance,
        addonIncome,
        bookedRevenue,
        appointmentsMade,
        commissionPayable,
        ownerTake,
        averageAppointmentValue,
        unresolvedAddons,
        commissionsAboveBalance,
      ];
}

class MemberRow extends Equatable {
  final int? memberId;
  final String name;
  final double income;
  final double bookedRevenue;
  final int appointmentsMade;
  final double commissionEarned;
  final double averageAppointmentValue;

  const MemberRow({
    this.memberId,
    required this.name,
    required this.income,
    required this.bookedRevenue,
    required this.appointmentsMade,
    required this.commissionEarned,
    this.averageAppointmentValue = 0,
  });

  @override
  List<Object?> get props =>
      [memberId, name, income, bookedRevenue, appointmentsMade, commissionEarned, averageAppointmentValue];
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
  final double? ownerTakeChange;

  const Comparison({
    required this.previousFrom,
    required this.previousTo,
    this.totalIncomeChange,
    this.bookedRevenueChange,
    this.appointmentsMadeChange,
    this.commissionPayableChange,
    this.ownerTakeChange,
  });

  @override
  List<Object?> get props => [
        previousFrom,
        previousTo,
        totalIncomeChange,
        bookedRevenueChange,
        appointmentsMadeChange,
        commissionPayableChange,
        ownerTakeChange,
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
