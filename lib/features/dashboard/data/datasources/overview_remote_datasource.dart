import 'package:dio/dio.dart';
import '../../domain/entities/overview.dart';
import '../../domain/entities/timeframe.dart';
import '../models/overview_models.dart';

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

class OverviewRemoteDatasource {
  final Dio client;
  OverviewRemoteDatasource({required this.client});

  /// The dates are plain `yyyy-MM-dd` (Paris time), sent without any timezone conversion.
  Future<Overview> getOverview({
    required int businessId,
    required Timeframe timeframe,
    required OverviewBucket groupBy,
  }) async {
    final r = await client.get('/business/$businessId/overview', queryParameters: {
      'from': _isoDate(timeframe.start),
      'to': _isoDate(timeframe.end),
      'group_by': groupBy.name,
    });
    return overviewFromJson(r.data);
  }
}
