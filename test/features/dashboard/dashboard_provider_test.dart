import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/dashboard/domain/entities/overview.dart';
import 'package:photography_business_frontend/features/dashboard/domain/entities/timeframe.dart';
import 'package:photography_business_frontend/features/dashboard/domain/repositories/overview_repository.dart';
import 'package:photography_business_frontend/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:photography_business_frontend/features/dashboard/presentation/providers/state/dashboard_view_state.dart';

class Call {
  final int businessId;
  final Timeframe timeframe;
  final OverviewBucket groupBy;
  Call(this.businessId, this.timeframe, this.groupBy);
}

class FakeOverviewRepository implements OverviewRepository {
  final calls = <Call>[];
  Overview overview = const Overview();
  Failure? failure;
  Completer<void>? gate;

  @override
  Future<Either<Failure, Overview>> getOverview({
    required int businessId,
    required Timeframe timeframe,
    required OverviewBucket groupBy,
  }) async {
    calls.add(Call(businessId, timeframe, groupBy));
    if (gate != null) await gate!.future;
    final f = failure;
    return f != null ? Left(f) : Right(overview);
  }
}

Business _business(int id) => Business(
      id: id,
      name: 'B$id',
      ownerId: 1,
      isActive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

DateTime _d(int y, int m, int d) => DateTime.utc(y, m, d);

const _figures = BusinessFigures(
  totalIncome: 1000,
  bookedRevenue: 1500,
  appointmentsMade: 12,
  commissionPayable: 300,
  unresolvedAddons: 0,
  commissionsAboveBalance: 0,
);

Comparison _comparison({
  double? income = 10,
  double? booked = -5,
  double? appointments,
  double? commission = 20,
}) =>
    Comparison(
      previousFrom: _d(2026, 9, 1),
      previousTo: _d(2026, 9, 30),
      totalIncomeChange: income,
      bookedRevenueChange: booked,
      appointmentsMadeChange: appointments,
      commissionPayableChange: commission,
    );

void main() {
  late FakeOverviewRepository repo;
  late StateProvider<int> businessId;
  late ProviderContainer container;
  var subscribed = false;

  setUp(() {
    repo = FakeOverviewRepository();
    businessId = StateProvider<int>((_) => 1);
    container = ProviderContainer(overrides: [
      overviewRepositoryProvider.overrideWithValue(repo),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 15, 14, 30)),
      selectedBusinessProvider.overrideWith((ref) => _business(ref.watch(businessId))),
    ]);
    addTearDown(container.dispose);
    subscribed = false;
  });

  // Keeps the auto-disposing provider alive between reads, as the page does;
  // started lazily so a test can arrange the fake before the first fetch.
  void keepAlive() {
    if (subscribed) return;
    subscribed = true;
    container.listen(dashboardProvider, (_, __) {});
  }

  Future<DashboardViewState> loaded() {
    keepAlive();
    return container.read(dashboardProvider.future);
  }

  group('Timeframe and request', () {
    test('opens on the current month, asking for day buckets', () async {
      await loaded();

      expect(repo.calls, hasLength(1));
      expect(repo.calls.single.businessId, 1);
      expect(repo.calls.single.timeframe.start, _d(2026, 10, 1));
      expect(repo.calls.single.timeframe.end, _d(2026, 10, 31));
      expect(repo.calls.single.groupBy, OverviewBucket.day);
      expect(container.read(timeframeProvider).preset, TimeframePreset.thisMonth);
    });

    test('presets resolve to their inclusive ranges', () {
      final today = DateTime(2026, 10, 15);
      Timeframe p(TimeframePreset x) => Timeframe.preset(x, today: today);

      expect(p(TimeframePreset.thisMonth).start, _d(2026, 10, 1));
      expect(p(TimeframePreset.thisMonth).end, _d(2026, 10, 31));
      expect(p(TimeframePreset.lastMonth).start, _d(2026, 9, 1));
      expect(p(TimeframePreset.lastMonth).end, _d(2026, 9, 30));
      expect(p(TimeframePreset.last30Days).start, _d(2026, 9, 16));
      expect(p(TimeframePreset.last30Days).end, _d(2026, 10, 15));
      expect(p(TimeframePreset.thisYear).start, _d(2026, 1, 1));
      expect(p(TimeframePreset.thisYear).end, _d(2026, 12, 31));
    });

    test('last month of January is December of the previous year', () {
      final t = Timeframe.preset(TimeframePreset.lastMonth, today: DateTime(2026, 1, 10));
      expect(t.start, _d(2025, 12, 1));
      expect(t.end, _d(2025, 12, 31));
    });

    test('a custom range may lie in the future and is requested as picked', () async {
      await loaded();
      container
          .read(timeframeProvider.notifier)
          .selectCustom(DateTime(2027, 3, 1), DateTime(2027, 3, 10));
      await loaded();

      final t = repo.calls.last.timeframe;
      expect(t.preset, TimeframePreset.custom);
      expect(t.start, _d(2027, 3, 1));
      expect(t.end, _d(2027, 3, 10));
    });

    test('31 days or less groups by day, up to about 120 by week, longer by month', () {
      Timeframe c(int days) => Timeframe.custom(_d(2026, 1, 1), _d(2026, 1, 1).add(Duration(days: days - 1)));

      expect(c(31).bucket, OverviewBucket.day);
      expect(c(32).bucket, OverviewBucket.week);
      expect(c(120).bucket, OverviewBucket.week);
      expect(c(121).bucket, OverviewBucket.month);
      expect(Timeframe.preset(TimeframePreset.thisYear, today: DateTime(2026, 5, 5)).bucket,
          OverviewBucket.month);
    });

    test('changing the Timeframe refetches with the matching range and bucket', () async {
      await loaded();
      container.read(timeframeProvider.notifier).selectPreset(TimeframePreset.thisYear);
      await loaded();

      expect(repo.calls, hasLength(2));
      expect(repo.calls.last.timeframe.start, _d(2026, 1, 1));
      expect(repo.calls.last.timeframe.end, _d(2026, 12, 31));
      expect(repo.calls.last.groupBy, OverviewBucket.month);
    });

    test('switching the Selected Business refetches over the same Timeframe', () async {
      container.read(timeframeProvider.notifier).selectPreset(TimeframePreset.lastMonth);
      await loaded();
      container.read(businessId.notifier).state = 2;
      await loaded();

      expect(repo.calls, hasLength(2));
      expect(repo.calls.last.businessId, 2);
      expect(repo.calls.last.timeframe, repo.calls.first.timeframe);
      expect(container.read(timeframeProvider).preset, TimeframePreset.lastMonth);
    });
  });

  group('loading and errors', () {
    test('is loading on first fetch', () {
      repo.gate = Completer();
      keepAlive();

      expect(container.read(dashboardProvider).isLoading, isTrue);
      expect(container.read(dashboardProvider).hasValue, isFalse);
      repo.gate!.complete();
    });

    test('previous data stays available while a refetch is in flight', () async {
      repo.overview = const Overview(business: _figures);
      await loaded();

      repo.gate = Completer();
      container.read(timeframeProvider.notifier).selectPreset(TimeframePreset.lastMonth);
      final during = container.read(dashboardProvider);

      expect(during.isLoading, isTrue);
      expect(during.value?.kpis.first.value, 1000);
      repo.gate!.complete();
    });

    test('a failure is an error state and a retry refetches', () async {
      repo.failure = const ServerFailure('boom');
      await expectLater(loaded(), throwsA(anything));
      expect(container.read(dashboardProvider).hasError, isTrue);

      repo.failure = null;
      container.invalidate(dashboardProvider);
      final state = await loaded();

      expect(repo.calls, hasLength(2));
      expect(state.kpis, isEmpty);
    });
  });

  group('headline figures', () {
    test('a full response gives four KPIs with change percents and tones', () async {
      repo.overview = Overview(
        business: _figures,
        comparison: _comparison(),
        members: const [],
      );
      final s = await loaded();

      expect(s.kpis.map((k) => k.label),
          ['Total income', 'Booked revenue', 'Appointments made', 'Commission payable']);
      expect(s.kpis.map((k) => k.value), [1000, 1500, 12, 300]);
      expect(s.kpis.map((k) => k.changePercent), [10, -5, null, 20]);
      expect(s.kpis.map((k) => k.tone),
          [ChangeTone.good, ChangeTone.bad, ChangeTone.neutral, ChangeTone.neutral]);
      expect(s.showChange, isTrue);
      expect(s.previousFrom, _d(2026, 9, 1));
      expect(s.previousTo, _d(2026, 9, 30));
    });

    test('a null comparison hides change badges', () async {
      repo.overview = const Overview(business: _figures);
      final s = await loaded();

      expect(s.showChange, isFalse);
      expect(s.previousFrom, isNull);
    });

    test('null business falls back to the single Member row, without badges', () async {
      repo.overview = const Overview(members: [
        MemberRow(
            name: 'Me', income: 200, bookedRevenue: 250, appointmentsMade: 3, commissionEarned: 80),
      ]);
      final s = await loaded();

      expect(s.kpis.map((k) => k.label),
          ['Income', 'Booked revenue', 'Appointments', 'Commission earned']);
      expect(s.kpis.map((k) => k.value), [200, 250, 3, 80]);
      expect(s.showChange, isFalse);
      expect(s.members, isEmpty);
      expect(s.isEmpty, isFalse);
    });

    test('commission earned is neutral in the fallback too', () async {
      repo.overview = Overview(
        comparison: _comparison(commission: 50),
        members: const [
          MemberRow(
              name: 'Me', income: 200, bookedRevenue: 250, appointmentsMade: 3, commissionEarned: 80),
        ],
      );
      final s = await loaded();

      expect(s.kpis.last.tone, ChangeTone.neutral);
    });
  });

  group('members', () {
    const rows = [
      MemberRow(name: 'A', income: 1, bookedRevenue: 1, appointmentsMade: 1, commissionEarned: 1),
      MemberRow(name: 'B', income: 2, bookedRevenue: 2, appointmentsMade: 2, commissionEarned: 2),
    ];

    test('several rows are listed', () async {
      repo.overview = const Overview(business: _figures, members: rows);
      final s = await loaded();

      expect(s.members.map((m) => m.name), ['A', 'B']);
    });

    test('a single row is hidden', () async {
      repo.overview = Overview(business: _figures, members: [rows.first]);
      final s = await loaded();

      expect(s.members, isEmpty);
    });
  });

  group('chart and empty state', () {
    test('series points carry deposit and balance per bucket', () async {
      repo.overview = Overview(business: _figures, series: [
        SeriesPoint(start: _d(2026, 10, 1), depositIncome: 100, balanceIncome: 50),
        SeriesPoint(start: _d(2026, 10, 2), depositIncome: 0, balanceIncome: 70),
      ]);
      final s = await loaded();

      expect(s.chart.map((p) => (p.start, p.depositIncome, p.balanceIncome)),
          [(_d(2026, 10, 1), 100.0, 50.0), (_d(2026, 10, 2), 0.0, 70.0)]);
      expect(s.isEmpty, isFalse);
    });

    test('a null series gives no chart points without error', () async {
      repo.overview = const Overview(business: _figures);
      final s = await loaded();

      expect(s.chart, isEmpty);
      expect(s.isEmpty, isFalse);
    });

    test('a period with no activity is empty and the figures read zero', () async {
      repo.overview = Overview(
        business: const BusinessFigures(
          totalIncome: 0,
          bookedRevenue: 0,
          appointmentsMade: 0,
          commissionPayable: 0,
          unresolvedAddons: 0,
          commissionsAboveBalance: 0,
        ),
        series: [SeriesPoint(start: _d(2026, 10, 1), depositIncome: 0, balanceIncome: 0)],
      );
      final s = await loaded();

      expect(s.isEmpty, isTrue);
      expect(s.kpis.map((k) => k.value), [0, 0, 0, 0]);
    });
  });

  group('alert chips', () {
    test('show their counts when above zero', () async {
      repo.overview = const Overview(
        business: BusinessFigures(
          totalIncome: 1,
          bookedRevenue: 1,
          appointmentsMade: 1,
          commissionPayable: 1,
          unresolvedAddons: 3,
          commissionsAboveBalance: 2,
        ),
      );
      final s = await loaded();

      expect(s.unresolvedAddons, 3);
      expect(s.commissionsAboveBalance, 2);
    });

    test('are zero when the counts are zero, or without business figures', () async {
      repo.overview = const Overview(business: _figures);
      var s = await loaded();
      expect(s.unresolvedAddons, 0);
      expect(s.commissionsAboveBalance, 0);

      repo.overview = const Overview();
      container.invalidate(dashboardProvider);
      s = await loaded();
      expect(s.unresolvedAddons, 0);
      expect(s.commissionsAboveBalance, 0);
    });
  });
}
