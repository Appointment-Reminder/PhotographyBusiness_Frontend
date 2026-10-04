import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import '../../data/datasources/overview_remote_datasource.dart';
import '../../data/repositories/overview_repository_impl.dart';
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

class DashboardLoadException implements Exception {
  final String message;
  DashboardLoadException(this.message);

  @override
  String toString() => message;
}

/// The overview of the Selected Business over the Timeframe. Changing either
/// refetches; while it does, the previous value stays on the AsyncValue.
/// Retry with `ref.invalidate(dashboardProvider)`.
final dashboardProvider = FutureProvider.autoDispose<DashboardViewState>((ref) async {
  final businessId = ref.watch(selectedBusinessProvider.select((b) => b?.id));
  final timeframe = ref.watch(timeframeProvider);
  if (businessId == null) throw DashboardLoadException('No business selected');

  final result = await ref.read(overviewRepositoryProvider).getOverview(
        businessId: businessId,
        timeframe: timeframe,
        groupBy: timeframe.bucket,
      );
  return result.fold(
    (f) => throw DashboardLoadException(f.message),
    DashboardViewState.fromOverview,
  );
});
