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
  Future<Either<Failure, MemberCommission>> createMemberCommission({
    required int businessMemberId,
    required int packageId,
    required int commissionAmount,
    required bool commissionIsPercent,
    required DateTime effectiveFrom,
  }) async {
    return _execute(() => remoteDatasource.createMemberCommission(
      businessMemberId: businessMemberId,
      packageId: packageId,
      commissionAmount: commissionAmount,
      commissionIsPercent: commissionIsPercent,
      effectiveFrom: effectiveFrom,
    ));
  }

  @override
  Future<Either<Failure, MemberCommission>> getMemberCommission({
    required int memberId,
    required int packageId,
  }) async {
    return _execute(() => remoteDatasource.getMemberCommission(
      memberId: memberId,
      packageId: packageId,
    ));
  }

  @override
  Future<Either<Failure, List<MemberCommission>>> getBusinessCommissions({required int businessId}) async {
    return _execute(() => remoteDatasource.getBusinessCommissions(businessId: businessId));
  }

  @override
  Future<Either<Failure, MemberCommission>> updateMemberCommission({
    required int id,
    required int commissionAmount,
    required bool commissionIsPercent
  }) {
    return _execute(() => remoteDatasource.updateMemberCommission(
        id: id,
        commissionAmount: commissionAmount,
        commissionIsPercent: commissionIsPercent));
  }

  @override
  Future<Either<Failure, BusinessMemberForm>> createMemberForm({
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    return _execute(() => remoteDatasource.createMemberForm(
      businessMemberId: businessMemberId,
      categoryId: categoryId,
      jotformFieldMap: jotformFieldMap,
    ));
  }

  @override
  Future<Either<Failure, BusinessMemberForm>> updateMemberForm({
    required int id,
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    return _execute(() => remoteDatasource.updateMemberForm(
      id: id,
      businessMemberId: businessMemberId,
      categoryId: categoryId,
      jotformFieldMap: jotformFieldMap,
    ));
  }

  @override
  Future<Either<Failure, List<BusinessMemberForm>>> getMemberForms({
    required int businessId,
    required int memberId,
  }) async {
    return _execute(() => remoteDatasource.getMemberForms(
      businessId: businessId,
      memberId: memberId,
    ));
  }

  @override
  Future<Either<Failure, List<BusinessMemberForm>>> getAllMemberForms({required int businessId}) {
    return _execute(() => remoteDatasource.getAllMemberForms(businessId: businessId));
  }

  @override
  Future<Either<Failure, void>> deleteMemberForm(int formId) async {
    return _execute(() => remoteDatasource.deleteMemberForm(formId));
  }






}