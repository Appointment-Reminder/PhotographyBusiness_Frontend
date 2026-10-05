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
  depositIncome: 400,
  packageBalance: 500,
  addonIncome: 100,
  bookedRevenue: 1500,
  appointmentsMade: 12,
  commissionPayable: 300,
  ownerTake: 250,
  averageAppointmentValue: 125,
  unresolvedAddons: 0,
  commissionsAboveBalance: 0,
);

/// [_figures] with some fields overridden; an explicit null owner take means an admin.
BusinessFigures _figs({
  double totalIncome = 1000,
  double depositIncome = 400,
  double packageBalance = 500,
  double addonIncome = 100,
  double bookedRevenue = 1500,
  int appointmentsMade = 12,
  double commissionPayable = 300,
  double? ownerTake = 250,
  double averageAppointmentValue = 125,
  int unresolvedAddons = 0,
  int commissionsAboveBalance = 0,
}) =>
    BusinessFigures(
      totalIncome: totalIncome,
      depositIncome: depositIncome,
      packageBalance: packageBalance,
      addonIncome: addonIncome,
      bookedRevenue: bookedRevenue,
      appointmentsMade: appointmentsMade,
      commissionPayable: commissionPayable,
      ownerTake: ownerTake,
      averageAppointmentValue: averageAppointmentValue,
      unresolvedAddons: unresolvedAddons,
      commissionsAboveBalance: commissionsAboveBalance,
    );

const _me = MemberRow(
  memberId: 7,
  name: 'Noah',
  income: 400,
  bookedRevenue: 250,
  appointmentsMade: 3,
  commissionEarned: 80,
  averageAppointmentValue: 83,
);
const _other = MemberRow(
  memberId: 8,
  name: 'Olivia Martin',
  income: 200,
  bookedRevenue: 300,
  appointmentsMade: 2,
  commissionEarned: 50,
  averageAppointmentValue: 150,
);
const _idle = MemberRow(
  memberId: 9,
  name: 'Emma Davis',
  income: 0,
  bookedRevenue: 0,
  appointmentsMade: 0,
  commissionEarned: 0,
  averageAppointmentValue: 0,
);

Comparison _comparison({
  double? income = 10,
  double? booked = -5,
  double? appointments,
  double? commission = 20,
  double? ownerTake = 5,
}) =>
    Comparison(
      previousFrom: _d(2026, 9, 1),
      previousTo: _d(2026, 9, 30),
      totalIncomeChange: income,
      bookedRevenueChange: booked,
      appointmentsMadeChange: appointments,
      commissionPayableChange: commission,
      ownerTakeChange: ownerTake,
    );

void main() {
  late FakeOverviewRepository repo;
  late StateProvider<int> businessId;
  late StateProvider<int?> me;
  late ProviderContainer container;
  var subscribed = false;

  setUp(() {
    repo = FakeOverviewRepository();
    businessId = StateProvider<int>((_) => 1);
    me = StateProvider<int?>((_) => null);
    container = ProviderContainer(overrides: [
      overviewRepositoryProvider.overrideWithValue(repo),
      clockProvider.overrideWithValue(() => DateTime(2026, 10, 15, 14, 30)),
      selectedBusinessProvider.overrideWith((ref) => _business(ref.watch(businessId))),
      myMemberIdProvider.overrideWith((ref) => ref.watch(me)),
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

  group('chart bucket toggle', () {
    test('defaults to the automatic bucket for the Timeframe', () async {
      await loaded();

      expect(container.read(bucketProvider), OverviewBucket.day);
    });

    test('choosing a bucket refetches with that group_by over the same range', () async {
      await loaded();
      container.read(bucketChoiceProvider.notifier).select(OverviewBucket.week);
      await loaded();

      expect(repo.calls, hasLength(2));
      expect(repo.calls.last.groupBy, OverviewBucket.week);
      expect(repo.calls.last.timeframe, repo.calls.first.timeframe);
    });

    test('changing the Timeframe goes back to the automatic bucket', () async {
      await loaded();
      container.read(bucketChoiceProvider.notifier).select(OverviewBucket.week);
      await loaded();
      container.read(timeframeProvider.notifier).selectPreset(TimeframePreset.thisYear);
      await loaded();

      expect(container.read(bucketProvider), OverviewBucket.month);
      expect(repo.calls.last.groupBy, OverviewBucket.month);
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
      expect(during.value?.totalIncome?.kpi.value, 1000);
      repo.gate!.complete();
    });

    test('a failure is an error state and a retry refetches', () async {
      repo.failure = const ServerFailure('boom');
      await expectLater(loaded(), throwsA(anything));
      expect(container.read(dashboardProvider).hasError, isTrue);

      repo.failure = null;
      container.invalidate(overviewProvider);
      final state = await loaded();

      expect(repo.calls, hasLength(2));
      expect(state.totalIncome, isNull);
    });
  });

  group('cards', () {
    test('a full response gives each card its figure, change and tone', () async {
      repo.overview = Overview(business: _figures, comparison: _comparison());
      final s = await loaded();

      expect(s.totalIncome!.kpi.value, 1000);
      expect(s.totalIncome!.kpi.changePercent, 10);
      expect(s.totalIncome!.kpi.tone, ChangeTone.good);
      expect(s.bookedRevenue!.value, 1500);
      expect(s.bookedRevenue!.changePercent, -5);
      expect(s.bookedRevenue!.tone, ChangeTone.bad);
      expect(s.appointments!.value, 12);
      expect(s.appointments!.changePercent, isNull);
      expect(s.appointments!.showChange, isTrue);
      expect(s.appointments!.tone, ChangeTone.neutral);
      expect(s.commissionPayable!.value, 300);
      expect(s.commissionPayable!.changePercent, 20);
      expect(s.commissionPayable!.tone, ChangeTone.neutral);
      expect(s.previousFrom, _d(2026, 9, 1));
      expect(s.previousTo, _d(2026, 9, 30));
    });

    test('a null comparison hides change badges', () async {
      repo.overview = const Overview(business: _figures);
      final s = await loaded();

      expect(s.totalIncome!.kpi.showChange, isFalse);
      expect(s.commissionPayable!.showChange, isFalse);
      expect(s.previousFrom, isNull);
    });

    test('Business earnings shows the owner take with its change', () async {
      repo.overview = Overview(business: _figures, comparison: _comparison(ownerTake: 8));
      final s = await loaded();

      expect(s.businessEarnings!.kpi.label, 'Business earnings');
      expect(s.businessEarnings!.kpi.value, 250);
      expect(s.businessEarnings!.kpi.changePercent, 8);
    });

    test('Business earnings is hidden when the owner take is null (an admin)', () async {
      repo.overview = Overview(business: _figs(ownerTake: null), comparison: _comparison());
      final s = await loaded();

      expect(s.businessEarnings, isNull);
      expect(s.commissionPayable, isNotNull);
      expect(s.totalIncome, isNotNull);
    });

    test('Average appointment value carries a neutral zero delta until the backend sends a previous value',
        () async {
      repo.overview = Overview(business: _figures, comparison: _comparison());
      final s = await loaded();

      expect(s.averageAppointmentValue!.label, 'Average appointment value');
      expect(s.averageAppointmentValue!.value, 125);
      expect(s.averageAppointmentValue!.deltaAmount, 0);
      expect(s.averageAppointmentValue!.tone, ChangeTone.neutral);
    });
  });

  group('income sources', () {
    test('Total income splits deposit, shooting session and add-ons with shares of their sum', () async {
      repo.overview = const Overview(business: _figures);
      final s = await loaded();
      final split = s.totalIncome!.split;

      expect((split.deposit, split.session, split.addons), (400, 500, 100));
      expect(split.share(split.deposit), 0.4);
      expect(split.share(split.session), 0.5);
      expect(split.share(split.addons), 0.1);
      expect(s.splitMismatch, isFalse);
    });

    test('a split that does not add up to Total income is flagged, not adjusted', () async {
      repo.overview = Overview(business: _figs(totalIncome: 900));
      final s = await loaded();

      expect(s.splitMismatch, isTrue);
      expect(s.totalIncome!.kpi.value, 900);
      expect(s.totalIncome!.split.deposit, 400);
    });

    test('an all-zero split has zero shares', () {
      expect(IncomeSplit.unavailable.share(0), 0);
    });

    test('My earnings and Business earnings show a zero split until the backend sends one', () async {
      repo.overview = const Overview(
        business: _figures,
        members: [_me, _other],
      );
      container.read(me.notifier).state = 7;
      final s = await loaded();

      expect(s.myEarnings!.split, IncomeSplit.unavailable);
      expect(s.businessEarnings!.split, IncomeSplit.unavailable);
    });
  });

  group('My earnings', () {
    test("is the commission earned on the logged-in Member's row", () async {
      repo.overview = const Overview(business: _figures, members: [_other, _me]);
      container.read(me.notifier).state = 7;
      final s = await loaded();

      expect(s.myEarnings!.kpi.label, 'My earnings');
      expect(s.myEarnings!.kpi.value, 80);
      expect(s.myEarnings!.kpi.showChange, isFalse);
    });

    test('is hidden when no row matches the logged-in Member', () async {
      repo.overview = const Overview(business: _figures, members: [_other, _me]);
      container.read(me.notifier).state = 99;
      final s = await loaded();

      expect(s.myEarnings, isNull);
    });

    test('is hidden when the logged-in Member is unknown and several rows exist', () async {
      repo.overview = const Overview(business: _figures, members: [_other, _me]);
      final s = await loaded();

      expect(s.myEarnings, isNull);
    });
  });

  group('photographer view (no business figures)', () {
    test('is built from their own row with no business cards and no badges', () async {
      repo.overview = const Overview(members: [_me]);
      final s = await loaded();

      expect(s.myEarnings!.kpi.value, 80);
      expect(s.bookedRevenue!.value, 250);
      expect(s.appointments!.value, 3);
      expect(s.averageAppointmentValue!.value, 83);
      expect(s.averageAppointmentValue!.deltaAmount, isNull);
      expect(s.totalIncome, isNull);
      expect(s.businessEarnings, isNull);
      expect(s.commissionPayable, isNull);
      expect(s.bookedRevenue!.showChange, isFalse);
      expect(s.members, isEmpty);
      expect(s.isEmpty, isFalse);
    });

    test('nothing at all when there are no rows either', () async {
      repo.overview = const Overview();
      final s = await loaded();

      expect(s.myEarnings, isNull);
      expect(s.bookedRevenue, isNull);
      expect(s.isEmpty, isTrue);
    });
  });

  group('members', () {
    test('several rows are listed with initials and effective rate', () async {
      repo.overview = const Overview(business: _figures, members: [_other, _me]);
      final s = await loaded();

      expect(s.members.map((m) => m.name), ['Olivia Martin', 'Noah']);
      expect(s.members.map((m) => m.initials), ['OM', 'N']);
      expect(s.members.map((m) => m.income), [200, 400]);
      expect(s.members.map((m) => m.appointmentsMade), [2, 3]);
      expect(s.members.map((m) => m.commissionEarned), [50, 80]);
      expect(s.members.map((m) => m.effectiveRate), [0.25, 0.2]);
    });

    test('the effective rate is absent when a Member earned no income', () async {
      repo.overview = const Overview(business: _figures, members: [_other, _idle]);
      final s = await loaded();

      expect(s.members.last.effectiveRate, isNull);
    });

    test('a single row is hidden', () async {
      repo.overview = const Overview(business: _figures, members: [_other]);
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

    test('a period with no activity is empty and the cards read zero', () async {
      repo.overview = Overview(
        business: _figs(
          totalIncome: 0,
          depositIncome: 0,
          packageBalance: 0,
          addonIncome: 0,
          bookedRevenue: 0,
          appointmentsMade: 0,
          commissionPayable: 0,
          ownerTake: 0,
          averageAppointmentValue: 0,
        ),
        series: [SeriesPoint(start: _d(2026, 10, 1), depositIncome: 0, balanceIncome: 0)],
      );
      final s = await loaded();

      expect(s.isEmpty, isTrue);
      expect(s.totalIncome!.kpi.value, 0);
      expect(s.bookedRevenue!.value, 0);
      expect(s.splitMismatch, isFalse);
    });
  });

  group('alert chips', () {
    test('show their counts when above zero', () async {
      repo.overview = Overview(
        business: _figs(unresolvedAddons: 3, commissionsAboveBalance: 2),
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
      container.invalidate(overviewProvider);
      s = await loaded();
      expect(s.unresolvedAddons, 0);
      expect(s.commissionsAboveBalance, 0);
    });
  });
}
