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

  @override
  Future<Either<Failure, Business>> createBusiness({required String name, String? description}) async {
    try{
      final isOnline = await networkInfo.isConnected;
      if(!isOnline){
        return Left(ServerFailure('No internet connection'));
      }

      final business = await remoteDatasource.createBusiness(
          name: name,
          description: description,
      );

      return Right(business);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBusiness(int businessId) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      await remoteDatasource.deleteBusiness(businessId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Business>> getBusinessById(int businessId) async {
    try{
      final isOnline = await networkInfo.isConnected;
      if(!isOnline){
        return Future.value(Left(ServerFailure('No internet connection')));
      }

      final business = await remoteDatasource.getBusinessById(businessId);
      return Right(business);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<BusinessMember>>> getBusinessMembers(int businessId) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final members = await remoteDatasource.getBusinessMembers(businessId);
      return Right(members);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<Business>>> getMyBusinesses({bool? isActive}) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if(!isOnline){
        return Left(ServerFailure('No internet connection'));
      }

      final businesses = await remoteDatasource.getMyBusinesses(isActive: isActive);
      return Right(businesses);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Business>> updateBusiness({required int businessId, String? name, String? description}) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final business = await remoteDatasource.updateBusiness(
        businessId: businessId,
        name: name,
        description: description,
      );
      return Right(business);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

}