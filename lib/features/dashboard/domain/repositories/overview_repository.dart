import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/overview.dart';
import '../entities/timeframe.dart';

abstract class OverviewRepository {
  /// The Business overview over [timeframe], its income series grouped by [groupBy].
  Future<Either<Failure, Overview>> getOverview({
    required int businessId,
    required Timeframe timeframe,
    required OverviewBucket groupBy,
  });
}
