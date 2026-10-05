import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';
import '../../data/datasources/overview_remote_datasource.dart';
import '../../data/repositories/overview_repository_impl.dart';
import '../../domain/entities/overview.dart';
import '../../domain/entities/timeframe.dart';
import '../../domain/repositories/overview_repository.dart';
import 'state/dashboard_view_state.dart';

final overviewRepositoryProvider = Provider<OverviewRepository>((ref) {
  return OverviewRepositoryImpl(
    remote: OverviewRemoteDatasource(client: ref.read(dioProvider)),
    networkInfo: ref.read(networkInfoProvider),
  );
});

/// Today, overridable in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

class TimeframeNotifier extends StateNotifier<Timeframe> {
  final DateTime Function() _now;

  TimeframeNotifier(this._now)
      : super(Timeframe.preset(TimeframePreset.thisMonth, today: _now()));

  void selectPreset(TimeframePreset preset) =>
      state = Timeframe.preset(preset, today: _now());

  void selectCustom(DateTime start, DateTime end) => state = Timeframe.custom(start, end);
}

/// The Dashboard Timeframe: kept while the Selected Business changes, held in
/// memory only so it is back on This month after a restart.
final timeframeProvider = StateNotifierProvider<TimeframeNotifier, Timeframe>(
    (ref) => TimeframeNotifier(ref.read(clockProvider)));

/// A bucket the user picked on the chart toggle, valid only for the Timeframe it was
/// picked on; any other Timeframe goes back to its automatic bucket.
class BucketChoice {
  final Timeframe timeframe;
  final OverviewBucket bucket;
  const BucketChoice(this.timeframe, this.bucket);
}

class BucketChoiceNotifier extends StateNotifier<BucketChoice?> {
  final Ref _ref;
  BucketChoiceNotifier(this._ref) : super(null);

  void select(OverviewBucket bucket) =>
      state = BucketChoice(_ref.read(timeframeProvider), bucket);
}

final bucketChoiceProvider =
    StateNotifierProvider<BucketChoiceNotifier, BucketChoice?>((ref) => BucketChoiceNotifier(ref));

/// The bucket the chart groups by: the user's choice for this Timeframe, else the automatic one.
final bucketProvider = Provider<OverviewBucket>((ref) {
  final timeframe = ref.watch(timeframeProvider);
  final choice = ref.watch(bucketChoiceProvider);
  return choice != null && choice.timeframe == timeframe ? choice.bucket : timeframe.bucket;
});

class DashboardLoadException implements Exception {
  final String message;
  DashboardLoadException(this.message);

  @override
  String toString() => message;
}

/// The raw overview of the Selected Business over the Timeframe. Changing either
/// refetches; while it does, the previous value stays on the AsyncValue.
/// Retry with `ref.invalidate(overviewProvider)`.
final overviewProvider = FutureProvider.autoDispose<Overview>((ref) async {
  final businessId = ref.watch(selectedBusinessProvider.select((b) => b?.id));
  final timeframe = ref.watch(timeframeProvider);
  final bucket = ref.watch(bucketProvider);
  if (businessId == null) throw DashboardLoadException('No business selected');

  final result = await ref.read(overviewRepositoryProvider).getOverview(
        businessId: businessId,
        timeframe: timeframe,
        groupBy: bucket,
      );
  return result.fold((f) => throw DashboardLoadException(f.message), (o) => o);
});

/// The logged-in Member's id in the Selected Business, once the Members are loaded.
final myMemberIdProvider = Provider.autoDispose<int?>((ref) {
  final businessId = ref.watch(selectedBusinessProvider.select((b) => b?.id));
  final auth = ref.watch(authNotifierProvider);
  if (businessId == null || auth is! AuthAuthenticated) return null;
  final members = ref.watch(businessMembersProvider(businessId)).members;
  for (final m in members) {
    if (m.userId == auth.user.id) return m.id;
  }
  return null;
});

/// What the Dashboard renders. Knowing the logged-in Member does not refetch the overview.
final dashboardProvider = FutureProvider.autoDispose<DashboardViewState>((ref) async {
  final overview = await ref.watch(overviewProvider.future);
  return DashboardViewState.fromOverview(overview, myMemberId: ref.watch(myMemberIdProvider));
});
