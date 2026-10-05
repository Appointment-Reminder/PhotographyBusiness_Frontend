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
const _sessionColor = Color(0xFF9DB5A0);
const _addonsColor = Color(0xFFD4D4D8);
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
          const _Header(),
          const SizedBox(height: 24),
          if (async.hasError && !async.isLoading)
            _ErrorBanner(
              message: async.error.toString(),
              onRetry: () => ref.invalidate(overviewProvider),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Business overview', style: AppTextStyles.heading24),
            const SizedBox(height: 4),
            Text('Track revenue, earnings, and your team\'s performance.', style: AppTextStyles.muted14),
          ],
        ),
        const _TimeframePicker(),
      ],
    );
  }
}

/// Lays children side by side with the given flex when wide, stacked when narrow.
class _Cards extends StatelessWidget {
  final List<(int flex, Widget child)> items;
  const _Cards(this.items);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(builder: (context, c) {
        if (c.maxWidth < 760) {
          return Column(children: [
            for (final (i, it) in items.indexed) ...[
              if (i > 0) const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: it.$2),
            ],
          ]);
        }
        return IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            for (final (i, it) in items.indexed) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(flex: it.$1, child: it.$2),
            ],
          ]),
        );
      }),
    );
  }
}

class _Body extends ConsumerWidget {
  final DashboardViewState data;
  const _Body({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topCards = [data.myEarnings, data.businessEarnings].whereType<SplitKpi>();
    final bottomCards = [data.bookedRevenue, data.appointments, data.appointmentsBooked, data.averageAppointmentValue].whereType<Kpi>();
    final chart = _ChartPanel(data: data);

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
        _Cards([
          for (final c in topCards) (1, _EarningsCard(card: c, data: data)),
          if (data.commissionPayable != null) (1, _StatCard(kpi: data.commissionPayable!, data: data)),
        ]),
        if (data.totalIncome != null)
          _Cards([(2, _TotalIncomeCard(card: data.totalIncome!, data: data)), (3, chart)])
        else
          _Cards([(1, chart)]),
        _Cards([for (final k in bottomCards) (1, _StatCard(kpi: k, data: data))]),
        if (data.members.isNotEmpty) _Panel(title: 'Member performance', child: _MembersTable(rows: data.members)),
      ],
    );
  }
}

class _TimeframePicker extends ConsumerWidget {
  const _TimeframePicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(timeframeProvider);
    final notifier = ref.read(timeframeProvider.notifier);

    return PopupMenuButton<TimeframePreset>(
      tooltip: 'Timeframe',
      onSelected: (p) async {
        if (p != TimeframePreset.custom) return notifier.selectPreset(p);
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          initialDateRange: DateTimeRange(start: t.start, end: t.end),
        );
        if (picked != null) notifier.selectCustom(picked.start, picked.end);
      },
      itemBuilder: (_) => [
        for (final p in TimeframePreset.values)
          CheckedPopupMenuItem(value: p, checked: t.preset == p, child: Text(p.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: _boxDecoration,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_today_outlined, size: 16),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.preset.label, style: AppTextStyles.body.copyWith(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('${_short.format(t.start)} – ${_long.format(t.end)}', style: AppTextStyles.muted12),
          ]),
          const SizedBox(width: 12),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ]),
      ),
    );
  }
}

Color _toneColor(ChangeTone tone) => switch (tone) {
      ChangeTone.good => _good,
      ChangeTone.bad => _bad,
      ChangeTone.neutral => AppColors.mutedText,
    };

/// The change badge and previous-range caption under a figure; nothing when the card has none.
class _Change extends StatelessWidget {
  final Kpi kpi;
  final DashboardViewState data;
  const _Change({required this.kpi, required this.data});

  @override
  Widget build(BuildContext context) {
    final delta = kpi.deltaAmount;
    if (delta != null) {
      final prefix = delta == 0 ? '' : (delta > 0 ? 'Up ' : 'Down ');
      return Text('$prefix${formatAmount(delta.abs())} from last period',
          style: AppTextStyles.muted.copyWith(fontSize: 11, color: _toneColor(kpi.tone)));
    }
    if (!kpi.showChange) return const SizedBox.shrink();
    final change = kpi.changePercent;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        change == null ? '—' : '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}%',
        style: AppTextStyles.body.copyWith(fontSize: 13, color: _toneColor(kpi.tone), fontWeight: FontWeight.w600),
      ),
      if (data.previousFrom != null && data.previousTo != null)
        Text('vs ${_short.format(data.previousFrom!)} – ${_short.format(data.previousTo!)}',
            style: AppTextStyles.muted.copyWith(fontSize: 11)),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final Kpi kpi;
  final DashboardViewState data;
  const _StatCard({required this.kpi, required this.data});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: _boxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(kpi.label, style: AppTextStyles.muted14),
            const SizedBox(height: 8),
            Text(formatAmount(kpi.value), style: AppTextStyles.heading24),
            const SizedBox(height: 6),
            _Change(kpi: kpi, data: data),
          ],
        ),
      );
}

class _EarningsCard extends StatelessWidget {
  final SplitKpi card;
  final DashboardViewState data;
  const _EarningsCard({required this.card, required this.data});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: _boxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.kpi.label, style: AppTextStyles.muted14),
            const SizedBox(height: 8),
            Text(formatAmount(card.kpi.value), style: AppTextStyles.heading24),
            const SizedBox(height: 6),
            _Change(kpi: card.kpi, data: data),
            const SizedBox(height: 16),
            _SplitBar(split: card.split),
            const SizedBox(height: 12),
            _SplitLegend(split: card.split),
            if (card.mismatch) const _MismatchNote(),
          ],
        ),
      );
}

class _TotalIncomeCard extends StatelessWidget {
  final SplitKpi card;
  final DashboardViewState data;
  const _TotalIncomeCard({required this.card, required this.data});

  @override
  Widget build(BuildContext context) {
    final s = card.split;
    Widget line(Color color, String label, double amount) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: AppTextStyles.body14)),
            Text('${(s.share(amount) * 100).round()}%', style: AppTextStyles.muted12),
            const SizedBox(width: 20),
            SizedBox(
              width: 80,
              child: Text(formatAmount(amount), textAlign: TextAlign.right, style: AppTextStyles.body14),
            ),
          ]),
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.kpi.label, style: AppTextStyles.muted14),
          const SizedBox(height: 8),
          Text(formatAmount(card.kpi.value), style: AppTextStyles.heading24),
          const SizedBox(height: 6),
          _Change(kpi: card.kpi, data: data),
          const SizedBox(height: 16),
          _SplitBar(split: s),
          const SizedBox(height: 8),
          line(_depositColor, 'Deposit', s.deposit),
          line(_sessionColor, 'Shooting session', s.session),
          line(_addonsColor, 'Add-ons', s.addons),
          if (card.mismatch) const _MismatchNote(),
        ],
      ),
    );
  }
}

class _MismatchNote extends StatelessWidget {
  const _MismatchNote();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('The breakdown does not add up to the total.',
            style: AppTextStyles.muted12.copyWith(color: _bad)),
      );
}

/// Deposit / Shooting session / Add-ons as one proportional bar; a neutral track when all are 0.
class _SplitBar extends StatelessWidget {
  final IncomeSplit split;
  const _SplitBar({required this.split});

  @override
  Widget build(BuildContext context) {
    final parts = [
      (split.deposit, _depositColor),
      (split.session, _sessionColor),
      (split.addons, _addonsColor),
    ].where((p) => p.$1 > 0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: split.sum == 0
            ? const ColoredBox(color: _addonsColor)
            : Row(children: [
                for (final p in parts) Expanded(flex: (split.share(p.$1) * 1000).round().clamp(1, 1000), child: ColoredBox(color: p.$2)),
              ]),
      ),
    );
  }
}

class _SplitLegend extends StatelessWidget {
  final IncomeSplit split;
  const _SplitLegend({required this.split});

  @override
  Widget build(BuildContext context) {
    Widget item(Color color, String label, double amount) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: AppTextStyles.muted12)),
            ]),
            const SizedBox(height: 2),
            Text(formatAmount(amount), style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
          ]),
        );
    return Row(children: [
      item(_depositColor, 'Deposit', split.deposit),
      item(_sessionColor, 'Session', split.session),
      item(_addonsColor, 'Add-ons', split.addons),
    ]);
  }
}

class _ChartPanel extends ConsumerWidget {
  final DashboardViewState data;
  const _ChartPanel({required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bucket = ref.watch(bucketProvider);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Income over time', style: AppTextStyles.heading16),
                const SizedBox(height: 2),
                Text('Deposit and balance collected this period', style: AppTextStyles.muted12),
              ]),
            ),
            SegmentedButton<OverviewBucket>(
              showSelectedIcon: false,
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              segments: const [
                ButtonSegment(value: OverviewBucket.day, label: Text('Daily')),
                ButtonSegment(value: OverviewBucket.week, label: Text('Weekly')),
                ButtonSegment(value: OverviewBucket.month, label: Text('Monthly')),
              ],
              selected: {bucket},
              onSelectionChanged: (s) => ref.read(bucketChoiceProvider.notifier).select(s.single),
            ),
          ]),
          const SizedBox(height: 16),
          if (data.isEmpty)
            const SizedBox(height: 160, child: Center(child: Text('No activity in this period')))
          else if (data.chart.isEmpty)
            const SizedBox(height: 160, child: Center(child: Text('No chart data')))
          else
            _IncomeChart(points: data.chart, bucket: bucket),
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
    final avatar = Icon(icon, size: 16, color: const Color(0xFFB45309));
    const bg = Color(0xFFFEF3C7);
    if (onTap == null) return Chip(avatar: avatar, label: Text(label), backgroundColor: bg);
    return ActionChip(avatar: avatar, label: Text(label), backgroundColor: bg, onPressed: onTap);
  }
}

class _IncomeChart extends StatelessWidget {
  final List<SeriesPoint> points;
  final OverviewBucket bucket;
  const _IncomeChart({required this.points, required this.bucket});

  String _label(DateTime d) => switch (bucket) {
        OverviewBucket.day => DateFormat('d MMM').format(d),
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
  final List<MemberResult> rows;
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
          DataColumn(label: Text('COMMISSION EARNED'), numeric: true),
          DataColumn(label: Text('COMMISSION RATE'), numeric: true),
        ],
        rows: [
          for (final m in rows)
            DataRow(cells: [
              DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
                if (!m.isUnassigned) ...[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.TNB_greyText,
                    child: Text(m.initials, style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(m.name),
              ])),
              DataCell(Text(formatAmount(m.income))),
              DataCell(Text('${m.appointmentsMade}')),
              DataCell(Text(formatAmount(m.commissionEarned))),
              DataCell(Text(m.commissionRate == null ? '—' : '${(m.commissionRate! * 100).round()}%')),
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
        padding: const EdgeInsets.all(20),
        decoration: _boxDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.heading16),
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
