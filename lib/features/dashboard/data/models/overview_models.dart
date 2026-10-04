import '../../domain/entities/overview.dart';

double _d(Object? v) => (v as num).toDouble();
double? _dn(Object? v) => (v as num?)?.toDouble();

Overview overviewFromJson(Map<String, dynamic> j) {
  final b = j['business'] as Map<String, dynamic>?;
  final c = j['comparison'] as Map<String, dynamic>?;
  final s = j['series'] as List?;
  return Overview(
    business: b == null
        ? null
        : BusinessFigures(
            totalIncome: _d(b['total_income']),
            bookedRevenue: _d(b['booked_revenue']),
            appointmentsMade: b['appointments_made'],
            commissionPayable: _d(b['commission_payable']),
            unresolvedAddons: b['unresolved_addons'],
            commissionsAboveBalance: b['commissions_above_balance'],
          ),
    members: [
      for (final m in (j['members'] as List? ?? const []))
        MemberRow(
          name: m['name'] ?? '',
          income: _d(m['income']),
          bookedRevenue: _d(m['booked_revenue']),
          appointmentsMade: m['appointments_made'],
          commissionEarned: _d(m['commission_earned']),
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
            commissionPayableChange: _dn(c['change_percent']['commission_payable']),
          ),
    series: s == null
        ? null
        : [
            for (final p in s)
              SeriesPoint(
                start: DateTime.parse(p['start']),
                depositIncome: _d(p['deposit_income']),
                balanceIncome: _d(p['balance_income']),
              ),
          ],
  );
}
