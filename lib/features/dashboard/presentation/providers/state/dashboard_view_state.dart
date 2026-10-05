import 'package:equatable/equatable.dart';
import '../../../domain/entities/overview.dart';

enum ChangeTone { good, bad, neutral }

class Kpi extends Equatable {
  final String label;
  final num value;

  /// Whether to show a change badge (and the previous-range caption) at all.
  final bool showChange;

  /// Percent change versus the previous period; null when the previous figure was zero.
  final double? changePercent;
  final ChangeTone tone;

  /// Amount change versus the previous period, for cards that show one; null otherwise.
  final double? deltaAmount;

  const Kpi({
    required this.label,
    required this.value,
    this.showChange = false,
    this.changePercent,
    this.tone = ChangeTone.neutral,
    this.deltaAmount,
  });

  @override
  List<Object?> get props => [label, value, showChange, changePercent, tone, deltaAmount];
}

/// An amount split by Income source: Deposit, Shooting session and Add-ons.
class IncomeSplit extends Equatable {
  final double deposit;
  final double session;
  final double addons;

  const IncomeSplit({required this.deposit, required this.session, required this.addons});

  /// What the backend cannot split yet (commission, owner take): every slice at 0.
  static const unavailable = IncomeSplit(deposit: 0, session: 0, addons: 0);

  double get sum => deposit + session + addons;

  /// [amount] as a fraction of the three slices together; 0 when they are all 0.
  double share(double amount) => sum == 0 ? 0 : amount / sum;

  @override
  List<Object?> get props => [deposit, session, addons];
}

/// A card that also shows its Income source split.
class SplitKpi extends Equatable {
  final Kpi kpi;
  final IncomeSplit split;

  const SplitKpi(this.kpi, this.split);

  @override
  List<Object?> get props => [kpi, split];
}

class MemberResult extends Equatable {
  final String name;
  final String initials;
  final double income;
  final int appointmentsMade;
  final double commissionEarned;

  /// Commission earned divided by income; null when income is 0.
  final double? effectiveRate;

  const MemberResult({
    required this.name,
    required this.initials,
    required this.income,
    required this.appointmentsMade,
    required this.commissionEarned,
    required this.effectiveRate,
  });

  @override
  List<Object?> get props => [name, initials, income, appointmentsMade, commissionEarned, effectiveRate];
}

/// What the Dashboard page renders, with no further logic. Whatever the
/// backend returned null or empty is simply absent here; nothing depends on
/// the Business Role.
class DashboardViewState extends Equatable {
  final SplitKpi? myEarnings;
  final SplitKpi? businessEarnings;
  final Kpi? commissionPayable;
  final SplitKpi? totalIncome;
  final Kpi? bookedRevenue;
  final Kpi? appointments;
  final Kpi? averageAppointmentValue;

  final DateTime? previousFrom;
  final DateTime? previousTo;
  final List<SeriesPoint> chart;

  /// Empty when it would only list one Member.
  final List<MemberResult> members;
  final int unresolvedAddons;
  final int commissionsAboveBalance;

  /// The Income source split does not add up to Total income.
  final bool splitMismatch;

  /// No activity in the period: every figure and every chart bucket is zero.
  final bool isEmpty;

  const DashboardViewState({
    this.myEarnings,
    this.businessEarnings,
    this.commissionPayable,
    this.totalIncome,
    this.bookedRevenue,
    this.appointments,
    this.averageAppointmentValue,
    this.previousFrom,
    this.previousTo,
    required this.chart,
    required this.members,
    required this.unresolvedAddons,
    required this.commissionsAboveBalance,
    required this.splitMismatch,
    required this.isEmpty,
  });

  /// [myMemberId] is the logged-in Member's id in the Selected Business, if known.
  factory DashboardViewState.fromOverview(Overview o, {int? myMemberId}) {
    final b = o.business;
    final c = o.comparison;
    final me = _myRow(o, b, myMemberId);

    Kpi? row(String label, num Function(MemberRow) f) =>
        me == null ? null : Kpi(label: label, value: f(me));

    final myEarnings =
        me == null ? null : SplitKpi(Kpi(label: 'My earnings', value: me.commissionEarned), IncomeSplit.unavailable);

    final businessSplit = b == null
        ? null
        : IncomeSplit(deposit: b.depositIncome, session: b.packageBalance, addons: b.addonIncome);

    final bookedRevenue = b != null
        ? _kpi('Booked revenue', b.bookedRevenue, c, c?.bookedRevenueChange, goodWhenUp: true)
        : row('Booked revenue', (m) => m.bookedRevenue);
    final appointments = b != null
        ? _kpi('Appointments made', b.appointmentsMade, c, c?.appointmentsMadeChange, goodWhenUp: true)
        : row('Appointments made', (m) => m.appointmentsMade);
    final averageValue = b != null
        // The backend sends no previous value yet: a neutral $0 change stands in.
        ? Kpi(label: 'Average appointment value', value: b.averageAppointmentValue, deltaAmount: 0)
        : row('Average appointment value', (m) => m.averageAppointmentValue);

    final chart = o.series ?? const <SeriesPoint>[];
    final values = <num>[
      if (myEarnings != null) myEarnings.kpi.value,
      if (b != null) ...[b.totalIncome, b.bookedRevenue, b.appointmentsMade, b.commissionPayable, b.ownerTake ?? 0],
      if (b == null && bookedRevenue != null) bookedRevenue.value,
      if (b == null && appointments != null) appointments.value,
    ];
    final noActivity = values.every((v) => v == 0) &&
        chart.every((p) => p.depositIncome == 0 && p.balanceIncome == 0);

    return DashboardViewState(
      myEarnings: myEarnings,
      businessEarnings: b?.ownerTake == null
          ? null
          : SplitKpi(
              _kpi('Business earnings', b!.ownerTake!, c, c?.ownerTakeChange, goodWhenUp: true),
              IncomeSplit.unavailable,
            ),
      commissionPayable: b == null
          ? null
          : _kpi('Commission payable', b.commissionPayable, c, c?.commissionPayableChange, goodWhenUp: false),
      totalIncome: b == null
          ? null
          : SplitKpi(_kpi('Total income', b.totalIncome, c, c?.totalIncomeChange, goodWhenUp: true), businessSplit!),
      bookedRevenue: bookedRevenue,
      appointments: appointments,
      averageAppointmentValue: averageValue,
      previousFrom: c?.previousFrom,
      previousTo: c?.previousTo,
      chart: chart,
      members: o.members.length > 1 ? [for (final m in o.members) _result(m)] : const [],
      unresolvedAddons: b?.unresolvedAddons ?? 0,
      commissionsAboveBalance: b?.commissionsAboveBalance ?? 0,
      splitMismatch: businessSplit != null && (businessSplit.sum - b!.totalIncome).abs() > 0.005,
      isEmpty: noActivity,
    );
  }

  /// The logged-in Member's row: matched by id, or the only row when there are no
  /// business figures (a photographer sees only themselves).
  static MemberRow? _myRow(Overview o, BusinessFigures? b, int? myMemberId) {
    if (myMemberId != null) {
      for (final m in o.members) {
        if (m.memberId == myMemberId) return m;
      }
    }
    return b == null && o.members.length == 1 ? o.members.single : null;
  }

  static MemberResult _result(MemberRow m) => MemberResult(
        name: m.name,
        initials: _initials(m.name),
        income: m.income,
        appointmentsMade: m.appointmentsMade,
        commissionEarned: m.commissionEarned,
        effectiveRate: m.income == 0 ? null : m.commissionEarned / m.income,
      );

  static String _initials(String name) => name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();

  /// A rise is good or bad only where it means something; [goodWhenUp] false is neutral.
  static Kpi _kpi(String label, num value, Comparison? comparison, double? change, {required bool goodWhenUp}) {
    final tone = !goodWhenUp || change == null || change == 0
        ? ChangeTone.neutral
        : change > 0
            ? ChangeTone.good
            : ChangeTone.bad;
    return Kpi(
      label: label,
      value: value,
      showChange: comparison != null,
      changePercent: change,
      tone: tone,
    );
  }

  @override
  List<Object?> get props => [
        myEarnings,
        businessEarnings,
        commissionPayable,
        totalIncome,
        bookedRevenue,
        appointments,
        averageAppointmentValue,
        previousFrom,
        previousTo,
        chart,
        members,
        unresolvedAddons,
        commissionsAboveBalance,
        splitMismatch,
        isEmpty,
      ];
}
