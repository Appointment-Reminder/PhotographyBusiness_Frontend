import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import '../../domain/entities/overview.dart';
import '../../domain/entities/timeframe.dart';
import '../../domain/repositories/overview_repository.dart';
import '../datasources/overview_remote_datasource.dart';

class OverviewRepositoryImpl implements OverviewRepository {
  final OverviewRemoteDatasource remote;
  final NetworkInfo networkInfo;

  OverviewRepositoryImpl({required this.remote, required this.networkInfo});

  @override
  Future<Either<Failure, Overview>> getOverview({
    required int businessId,
    required Timeframe timeframe,
    required OverviewBucket groupBy,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure('No internet connection'));
      }
      return Right(await remote.getOverview(
          businessId: businessId, timeframe: timeframe, groupBy: groupBy));
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }
}
