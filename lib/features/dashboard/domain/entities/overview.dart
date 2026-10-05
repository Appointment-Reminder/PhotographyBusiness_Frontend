import 'package:equatable/equatable.dart';

/// Business-wide headline figures. Absent for a photographer.
class BusinessFigures extends Equatable {
  final double totalIncome;
  final double depositIncome;
  final double shootingIncome;
  final double addonsIncome;
  final double bookedRevenue;
  final int appointmentsMade;
  final int appointmentsBooked;

  /// What the Business owes its Members (the photographers' share).
  final double commissionPayable;

  /// Owner only: null for an admin. The split parts add up to the total.
  final double? ownerTake;
  final double ownerTakeDeposit;
  final double ownerTakeShooting;
  final double ownerTakeAddons;
  final double averageAppointmentValue;
  final int unresolvedAddons;
  final int commissionsAboveBalance;

  const BusinessFigures({
    required this.totalIncome,
    this.depositIncome = 0,
    this.shootingIncome = 0,
    this.addonsIncome = 0,
    required this.bookedRevenue,
    required this.appointmentsMade,
    this.appointmentsBooked = 0,
    required this.commissionPayable,
    this.ownerTake,
    this.ownerTakeDeposit = 0,
    this.ownerTakeShooting = 0,
    this.ownerTakeAddons = 0,
    this.averageAppointmentValue = 0,
    required this.unresolvedAddons,
    required this.commissionsAboveBalance,
  });

  @override
  List<Object?> get props => [
        totalIncome,
        depositIncome,
        shootingIncome,
        addonsIncome,
        bookedRevenue,
        appointmentsMade,
        appointmentsBooked,
        commissionPayable,
        ownerTake,
        ownerTakeDeposit,
        ownerTakeShooting,
        ownerTakeAddons,
        averageAppointmentValue,
        unresolvedAddons,
        commissionsAboveBalance,
      ];
}

class MemberRow extends Equatable {
  /// Null on the row of appointments that have no photographer yet.
  final int? memberId;
  final String name;
  final double income;
  final double bookedRevenue;
  final int appointmentsMade;
  final int appointmentsBooked;
  final double commissionEarned;
  final double commissionDeposit;
  final double commissionShooting;
  final double commissionAddons;

  /// The Member's commission as a share of their shot revenue; null when there is none.
  final double? commissionRate;
  final double averageAppointmentValue;

  const MemberRow({
    this.memberId,
    required this.name,
    required this.income,
    required this.bookedRevenue,
    required this.appointmentsMade,
    this.appointmentsBooked = 0,
    required this.commissionEarned,
    this.commissionDeposit = 0,
    this.commissionShooting = 0,
    this.commissionAddons = 0,
    this.commissionRate,
    this.averageAppointmentValue = 0,
  });

  bool get isUnassigned => memberId == null;

  @override
  List<Object?> get props => [
        memberId,
        name,
        income,
        bookedRevenue,
        appointmentsMade,
        appointmentsBooked,
        commissionEarned,
        commissionDeposit,
        commissionShooting,
        commissionAddons,
        commissionRate,
        averageAppointmentValue,
      ];
}

/// The previous period and the change versus it; a null percent means the
/// previous figure was zero.
class Comparison extends Equatable {
  final DateTime previousFrom;
  final DateTime previousTo;
  final double? totalIncomeChange;
  final double? bookedRevenueChange;
  final double? appointmentsMadeChange;
  final double? appointmentsBookedChange;
  final double? commissionPayableChange;
  final double? ownerTakeChange;
  final double previousAverageAppointmentValue;

  const Comparison({
    required this.previousFrom,
    required this.previousTo,
    this.totalIncomeChange,
    this.bookedRevenueChange,
    this.appointmentsMadeChange,
    this.appointmentsBookedChange,
    this.commissionPayableChange,
    this.ownerTakeChange,
    this.previousAverageAppointmentValue = 0,
  });

  @override
  List<Object?> get props => [
        previousFrom,
        previousTo,
        totalIncomeChange,
        bookedRevenueChange,
        appointmentsMadeChange,
        appointmentsBookedChange,
        commissionPayableChange,
        ownerTakeChange,
        previousAverageAppointmentValue,
      ];
}

class SeriesPoint extends Equatable {
  final DateTime start;
  final double depositIncome;

  /// Shooting session and add-ons income together.
  final double balanceIncome;

  const SeriesPoint({required this.start, required this.depositIncome, required this.balanceIncome});

  @override
  List<Object?> get props => [start, depositIncome, balanceIncome];
}

class Overview extends Equatable {
  /// The logged-in Member's id in this Business; null when they have none.
  final int? myMemberId;
  final BusinessFigures? business;
  final List<MemberRow> members;
  final Comparison? comparison;
  final List<SeriesPoint>? series;

  const Overview({this.myMemberId, this.business, this.members = const [], this.comparison, this.series});

  @override
  List<Object?> get props => [myMemberId, business, members, comparison, series];
}
