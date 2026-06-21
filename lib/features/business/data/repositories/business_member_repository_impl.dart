
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_member_repository.dart';

import '../../../../core/error/dio_error_handler.dart';

class BusinessMemberRepositoryImpl implements BusinessMemberRepository {
  final BusinessRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  BusinessMemberRepositoryImpl({required this.remoteDatasource, required this.networkInfo});

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
  Future<Either<Failure, BusinessMember>> inviteMember({required int businessId, required String userEmail, required String role}) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final member = await remoteDatasource.inviteMember(
        businessId: businessId,
        userEmail: userEmail,
        role: role,
      );
      return Right(member);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, void>> removeMember({required int businessId, required int memberId}) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      await remoteDatasource.removeMember(
        businessId: businessId,
        memberId: memberId,
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, BusinessMember>> updateMemberRole({required int businessId, required int memberId, required String role, required bool isActive}) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final member = await remoteDatasource.updateMemberRole(
        businessId: businessId,
        memberId: memberId,
        role: role,
        isActive: isActive,
      );
      return Right(member);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }
}