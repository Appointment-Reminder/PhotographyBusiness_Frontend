import '../../domain/entities/overview.dart';

double _d(Object? v) => (v as num).toDouble();
double? _dn(Object? v) => (v as num?)?.toDouble();

Overview overviewFromJson(Map<String, dynamic> j) {
  final b = j['business'] as Map<String, dynamic>?;
  final c = j['comparison'] as Map<String, dynamic>?;
  final s = j['series'] as List?;
  return Overview(
    myMemberId: j['my_member_id'],
    business: b == null
        ? null
        : BusinessFigures(
            totalIncome: _d(b['total_income']),
            depositIncome: _d(b['deposit_income']),
            shootingIncome: _d(b['shooting_income']),
            addonsIncome: _d(b['addons_income']),
            bookedRevenue: _d(b['booked_revenue']),
            appointmentsMade: b['appointments_made'],
            appointmentsBooked: b['appointments_booked'],
            commissionPayable: _d(b['photographer_share_total']),
            ownerTake: _dn(b['owner_share_total']),
            ownerTakeDeposit: _dn(b['owner_share_deposit']) ?? 0,
            ownerTakeShooting: _dn(b['owner_share_shooting']) ?? 0,
            ownerTakeAddons: _dn(b['owner_share_addons']) ?? 0,
            averageAppointmentValue: _d(b['average_appointment_value']),
            unresolvedAddons: b['unresolved_addons'],
            commissionsAboveBalance: b['commissions_above_balance'],
          ),
    members: [
      for (final m in (j['members'] as List? ?? const []))
        MemberRow(
          memberId: m['member_id'],
          name: m['name'] ?? '',
          income: _d(m['total_income']),
          bookedRevenue: _d(m['booked_revenue']),
          appointmentsMade: m['appointments_made'],
          appointmentsBooked: m['appointments_booked'],
          commissionEarned: _d(m['photographer_share_total']),
          commissionDeposit: _d(m['photographer_share_deposit']),
          commissionShooting: _d(m['photographer_share_shooting']),
          commissionAddons: _d(m['photographer_share_addons']),
          commissionRate: _dn(m['photographer_share_rate']),
          averageAppointmentValue: _d(m['average_appointment_value']),
        ),
    ],
    comparison: c == null
        ? null
        : Comparison(
            previousFrom: DateTime.parse(c['previous_from']),
            previousTo: DateTime.parse(c['previous_to']),
            totalIncomeChange: _dn(c['change_percent']['total_income']),
            bookedRevenueChange: _dn(c['change_percent']['booked_revenue']),
            appointmentsMadeChange: _dn(c['change_percent']['appointments_made']),
            appointmentsBookedChange: _dn(c['change_percent']['appointments_booked']),
            commissionPayableChange: _dn(c['change_percent']['photographer_share_total']),
            ownerTakeChange: _dn(c['change_percent']['owner_share_total']),
            previousAverageAppointmentValue: _d(c['previous']['average_appointment_value']),
          ),
    series: s == null
        ? null
        : [
            for (final p in s)
              SeriesPoint(
                start: DateTime.parse(p['start']),
                depositIncome: _d(p['deposit_income']),
                balanceIncome: _d(p['shooting_income']) + _d(p['addons_income']),
              ),
          ],
  );
}
