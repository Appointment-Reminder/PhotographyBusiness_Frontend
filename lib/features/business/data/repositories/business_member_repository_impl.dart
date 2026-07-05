
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
  Future<Either<Failure, List<BusinessMember>>> getBusinessMembers(int businessId) async {
    return _execute(() => remoteDatasource.getBusinessMembers(businessId));
  }

  @override
  Future<Either<Failure, BusinessMember>> inviteMember({required int businessId, required String userEmail, required String role}) async {
    return _execute(() =>
        remoteDatasource.inviteMember(
          businessId: businessId,
          userEmail: userEmail,
          role: role,
        ));
  }

  @override
  Future<Either<Failure, void>> removeMember({required int businessId, required int memberId}) async {
    return _execute(() => remoteDatasource.removeMember(
      businessId: businessId,
      memberId: memberId,
    ));
  }

  @override
  Future<Either<Failure, BusinessMember>> updateMemberRole({required int businessId, required int memberId, required String role, required bool isActive}) async {
    return _execute(() => remoteDatasource.updateMemberRole(
      businessId: businessId,
      memberId: memberId,
      role: role,
      isActive: isActive,
    ));
  }

}