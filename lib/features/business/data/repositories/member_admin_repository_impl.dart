import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import 'package:photography_business_frontend/features/business/data/datasource/member_admin_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member_form.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';

class MemberAdminRepositoryImpl implements MemberAdminRepository {
  final MemberAdminRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  MemberAdminRepositoryImpl({required this.remoteDatasource, required this.networkInfo});

  @override
  Future<Either<Failure, MemberCommission>> createMemberCommission({
    required int businessMemberId,
    required int packageId,
    required int commissionPercent,
    required DateTime effectiveFrom,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final commission = await remoteDatasource.createMemberCommission(
        businessMemberId: businessMemberId,
        packageId: packageId,
        commissionPercent: commissionPercent,
        effectiveFrom: effectiveFrom,
      );

      return Right(commission);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, MemberCommission>> getMemberCommission({
    required int memberId,
    required int packageId,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final commission = await remoteDatasource.getMemberCommission(
        memberId: memberId,
        packageId: packageId,
      );

      return Right(commission);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, BusinessMemberForm>> createMemberForm({
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final form = await remoteDatasource.createMemberForm(
        businessMemberId: businessMemberId,
        categoryId: categoryId,
        jotformFieldMap: jotformFieldMap,
      );

      return Right(form);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, BusinessMemberForm>> updateMemberForm({
    required int id,
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final form = await remoteDatasource.updateMemberForm(
        id: id,
        businessMemberId: businessMemberId,
        categoryId: categoryId,
        jotformFieldMap: jotformFieldMap,
      );

      return Right(form);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<BusinessMemberForm>>> getMemberForms({
    required int businessId,
    required int memberId,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final forms = await remoteDatasource.getMemberForms(
        businessId: businessId,
        memberId: memberId,
      );

      return Right(forms);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMemberForm(int formId) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      await remoteDatasource.deleteMemberForm(formId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }
}