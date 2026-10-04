import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/core/Presentation/navigation/app_section.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/utils/money_format.dart';
import '../../domain/entities/overview.dart';
import '../../domain/entities/timeframe.dart';
import '../providers/dashboard_providers.dart';
import '../providers/state/dashboard_view_state.dart';

const _good = Color(0xFF16A34A);
const _bad = Color(0xFFDC2626);
const _depositColor = Color(0xFF18181B);
const _balanceColor = Color(0xFFA1A1AA);

final _short = DateFormat('d MMM');
final _long = DateFormat('d MMM yyyy');

/// Dashboard: the financial overview of the Selected Business over a Timeframe.
class DashboardPage extends ConsumerWidget {
  final int businessId;
  const DashboardPage({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final data = async.valueOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOGRAPHY STUDIO', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('Dashboard', style: AppTextStyles.heading24),
          const SizedBox(height: 24),
          const _TimeframeBar(),
          const SizedBox(height: 24),
          if (async.hasError && !async.isLoading)
            _ErrorBanner(
              message: async.error.toString(),
              onRetry: () => ref.invalidate(dashboardProvider),
            ),
          if (data == null && async.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (data != null) ...[
            if (async.isLoading) const LinearProgressIndicator(minHeight: 2),
            _Body(data: data),
          ],
        ],
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final DashboardViewState data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.unresolvedAddons > 0 || data.commissionsAboveBalance > 0) ...[
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (data.unresolvedAddons > 0)
              _AlertChip(
                icon: Icons.help_outline,
                label: '${data.unresolvedAddons} unresolved add-ons',
                onTap: () => navigateTo(ref, AppSection.appointments, SubView.appointmentList),
              ),
            if (data.commissionsAboveBalance > 0)
              _AlertChip(
                icon: Icons.warning_amber_rounded,
                label: '${data.commissionsAboveBalance} commissions above balance',
              ),
          ]),
          const SizedBox(height: 16),
        ],
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [for (final k in data.kpis) _KpiCard(kpi: k, data: data)],
        ),
        const SizedBox(height: 24),
        _Panel(
          title: 'Income',
          child: data.isEmpty
              ? const SizedBox(
                  height: 120,
                  child: Center(child: Text('No activity in this period')),
                )
              : data.chart.isEmpty
                  ? const SizedBox.shrink()
                  : _IncomeChart(points: data.chart, bucket: _bucketOf(data.chart)),
        ),
        if (data.members.isNotEmpty) ...[
          const SizedBox(height: 24),
          _Panel(title: 'Members', child: _MembersTable(rows: data.members)),
        ],
      ],
    );
  }

  /// The chart labels follow the spacing of the points the backend returned.
  OverviewBucket _bucketOf(List<SeriesPoint> p) {
    if (p.length < 2) return OverviewBucket.day;
    final gap = p[1].start.difference(p[0].start).inDays;
    return gap >= 28 ? OverviewBucket.month : (gap >= 7 ? OverviewBucket.week : OverviewBucket.day);
  }
}

class _TimeframeBar extends ConsumerWidget {
  const _TimeframeBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(timeframeProvider);
    final notifier = ref.read(timeframeProvider.notifier);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final p in TimeframePreset.values)
          ChoiceChip(
            label: Text(p.label),
            selected: t.preset == p,
            onSelected: (_) async {
              if (p != TimeframePreset.custom) return notifier.selectPreset(p);
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: DateTimeRange(start: t.start, end: t.end),
              );
              if (picked != null) notifier.selectCustom(picked.start, picked.end);
            },
          ),
        const SizedBox(width: 8),
        Text(
          '${_short.format(t.start)} – ${_long.format(t.end)}',
          style: AppTextStyles.monoMuted10.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final Kpi kpi;
  final DashboardViewState data;
  const _KpiCard({required this.kpi, required this.data});

  @override
  Widget build(BuildContext context) {
    final change = kpi.changePercent;
    final color = switch (kpi.tone) {
      ChangeTone.good => _good,
      ChangeTone.bad => _bad,
      ChangeTone.neutral => AppColors.mutedText,
    };

    return Container(
      width: 230,
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kpi.label.toUpperCase(), style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.6)),
          const SizedBox(height: 8),
          Text(formatAmount(kpi.value), style: AppTextStyles.heading24),
          if (data.showChange) ...[
            const SizedBox(height: 8),
            Text(
              change == null ? '—' : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
              style: AppTextStyles.body.copyWith(fontSize: 13, color: color, fontWeight: FontWeight.w600),
            ),
            if (data.previousFrom != null && data.previousTo != null)
              Text(
                'vs ${_short.format(data.previousFrom!)} – ${_short.format(data.previousTo!)}',
                style: AppTextStyles.muted.copyWith(fontSize: 11),
              ),
          ],
        ],
      ),
    );
  }
}

class _AlertChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _AlertChip({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: const Color(0xFFB45309)),
      label: Text(label),
      backgroundColor: const Color(0xFFFEF3C7),
      onPressed: onTap ?? () {},
    );
  }
}

class _IncomeChart extends StatelessWidget {
  final List<SeriesPoint> points;
  final OverviewBucket bucket;
  const _IncomeChart({required this.points, required this.bucket});

  String _label(DateTime d) => switch (bucket) {
        OverviewBucket.day => DateFormat('d').format(d),
        OverviewBucket.week => DateFormat('d MMM').format(d),
        OverviewBucket.month => DateFormat('MMM').format(d),
      };

  @override
  Widget build(BuildContext context) {
    final step = (points.length / 12).ceil().clamp(1, points.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 240,
          child: BarChart(BarChartData(
            gridData: const FlGridData(drawVerticalLine: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (v, meta) =>
                      Text(formatAmount(v), style: AppTextStyles.monoMuted10),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (v, meta) {
                    final i = v.toInt();
                    if (i < 0 || i >= points.length || i % step != 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(_label(points[i].start), style: AppTextStyles.monoMuted10),
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < points.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: points[i].depositIncome + points[i].balanceIncome,
                    width: points.length > 40 ? 6 : 14,
                    borderRadius: BorderRadius.zero,
                    rodStackItems: [
                      BarChartRodStackItem(0, points[i].depositIncome, _depositColor),
                      BarChartRodStackItem(points[i].depositIncome,
                          points[i].depositIncome + points[i].balanceIncome, _balanceColor),
                    ],
                  ),
                ]),
            ],
          )),
        ),
        const SizedBox(height: 12),
        const Row(children: [
          _Legend(color: _depositColor, label: 'Deposit'),
          SizedBox(width: 16),
          _Legend(color: _balanceColor, label: 'Balance'),
        ]),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.muted.copyWith(fontSize: 12)),
      ]);
}

class _MembersTable extends StatelessWidget {
  final List<MemberRow> rows;
  const _MembersTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    final header = AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.4);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingTextStyle: header,
        columns: const [
          DataColumn(label: Text('MEMBER')),
          DataColumn(label: Text('INCOME'), numeric: true),
          DataColumn(label: Text('APPOINTMENTS'), numeric: true),
          DataColumn(label: Text('COMMISSION'), numeric: true),
        ],
        rows: [
          for (final m in rows)
            DataRow(cells: [
              DataCell(Text(m.name)),
              DataCell(Text(formatAmount(m.income))),
              DataCell(Text('${m.appointmentsMade}')),
              DataCell(Text(formatAmount(m.commissionEarned))),
            ]),
        ],
      ),
    );
  }
}

final _boxDecoration = BoxDecoration(
  color: Colors.white,
  border: Border.all(color: AppColors.border),
  borderRadius: BorderRadius.circular(8),
);

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _boxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.6)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          border: Border.all(color: _bad),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, color: _bad),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}
