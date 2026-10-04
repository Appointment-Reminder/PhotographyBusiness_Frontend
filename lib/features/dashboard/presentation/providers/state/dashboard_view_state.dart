import 'package:equatable/equatable.dart';
import '../../../domain/entities/overview.dart';

enum ChangeTone { good, bad, neutral }

class Kpi extends Equatable {
  final String label;
  final num value;

  /// Percent change versus the previous period; null when the previous figure was zero.
  final double? changePercent;
  final ChangeTone tone;

  const Kpi({required this.label, required this.value, this.changePercent, this.tone = ChangeTone.neutral});

  @override
  List<Object?> get props => [label, value, changePercent, tone];
}

/// What the Dashboard page renders, with no further logic. Whatever the
/// backend returned null or empty is simply absent here; nothing depends on
/// the Business Role.
class DashboardViewState extends Equatable {
  final List<Kpi> kpis;

  /// Whether to show change badges and the previous-range caption.
  final bool showChange;
  final DateTime? previousFrom;
  final DateTime? previousTo;
  final List<SeriesPoint> chart;

  /// Empty when it would only list one Member.
  final List<MemberRow> members;
  final int unresolvedAddons;
  final int commissionsAboveBalance;

  /// No activity in the period: every figure and every chart bucket is zero.
  final bool isEmpty;

  const DashboardViewState({
    required this.kpis,
    required this.showChange,
    this.previousFrom,
    this.previousTo,
    required this.chart,
    required this.members,
    required this.unresolvedAddons,
    required this.commissionsAboveBalance,
    required this.isEmpty,
  });

  factory DashboardViewState.fromOverview(Overview o) {
    final b = o.business;
    final c = o.comparison;

    final List<Kpi> kpis;
    if (b != null) {
      kpis = [
        _kpi('Total income', b.totalIncome, c?.totalIncomeChange, goodWhenUp: true),
        _kpi('Booked revenue', b.bookedRevenue, c?.bookedRevenueChange, goodWhenUp: true),
        _kpi('Appointments made', b.appointmentsMade, c?.appointmentsMadeChange, goodWhenUp: true),
        _kpi('Commission payable', b.commissionPayable, c?.commissionPayableChange, goodWhenUp: false),
      ];
    } else if (o.members.isNotEmpty) {
      num sum(num Function(MemberRow) f) => o.members.fold<num>(0, (a, m) => a + f(m));
      kpis = [
        _kpi('Income', sum((m) => m.income), c?.totalIncomeChange, goodWhenUp: true),
        _kpi('Booked revenue', sum((m) => m.bookedRevenue), c?.bookedRevenueChange, goodWhenUp: true),
        _kpi('Appointments', sum((m) => m.appointmentsMade), c?.appointmentsMadeChange, goodWhenUp: true),
        _kpi('Commission earned', sum((m) => m.commissionEarned), c?.commissionPayableChange,
            goodWhenUp: false),
      ];
    } else {
      kpis = const [];
    }

    final chart = o.series ?? const <SeriesPoint>[];
    final noActivity = kpis.every((k) => k.value == 0) &&
        chart.every((p) => p.depositIncome == 0 && p.balanceIncome == 0);

    return DashboardViewState(
      kpis: kpis,
      showChange: c != null,
      previousFrom: c?.previousFrom,
      previousTo: c?.previousTo,
      chart: chart,
      members: o.members.length > 1 ? o.members : const [],
      unresolvedAddons: b?.unresolvedAddons ?? 0,
      commissionsAboveBalance: b?.commissionsAboveBalance ?? 0,
      isEmpty: noActivity,
    );
  }

  /// A rise is good or bad only where it means something; [goodWhenUp] false is neutral.
  static Kpi _kpi(String label, num value, double? change, {required bool goodWhenUp}) {
    final tone = !goodWhenUp || change == null || change == 0
        ? ChangeTone.neutral
        : change > 0
            ? ChangeTone.good
            : ChangeTone.bad;
    return Kpi(label: label, value: value, changePercent: change, tone: tone);
  }

  @override
  List<Object?> get props => [
        kpis,
        showChange,
        previousFrom,
        previousTo,
        chart,
        members,
        unresolvedAddons,
        commissionsAboveBalance,
        isEmpty,
      ];
}
