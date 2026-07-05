import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_repository.dart';

import '../../../../core/error/dio_error_handler.dart';
import '../../../../core/network/network_info.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  BusinessRepositoryImpl({required this.remoteDatasource, required this.networkInfo});

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try{
      if(!await networkInfo.isConnected){
        return const Left(ServerFailure('No internet connection'));
      }
      final result = await action();
      return Right(result);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    }
    catch (_) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Business>> createBusiness({required String name, String? description}) async {
    return _execute(() => remoteDatasource.createBusiness(
      name: name,
      description: description,
    ));
  }

  @override
  Future<Either<Failure, void>> deleteBusiness(int businessId) async {
    return _execute(() => remoteDatasource.deleteBusiness(businessId));
  }

  @override
  Future<Either<Failure, Business>> getBusinessById(int businessId) async {
    return _execute(() => remoteDatasource.getBusinessById(businessId));
  }

  @override
  Future<Either<Failure, List<BusinessMember>>> getBusinessMembers(int businessId) async {
    return _execute(() => remoteDatasource.getBusinessMembers(businessId));
  }

  @override
  Future<Either<Failure, List<Business>>> getMyBusinesses({bool? isActive}) async {
    return _execute(() => remoteDatasource.getMyBusinesses(isActive: isActive));
  }

  @override
  Future<Either<Failure, Business>> updateBusiness({required int businessId, String? name, String? description}) async {
    return _execute(() => remoteDatasource.updateBusiness(
      businessId: businessId,
      name: name,
      description: description,
    ));
  }

}