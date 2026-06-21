

import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/member_commission.dart';
import '../../repositories/business_repository.dart';
import '../member_params.dart';

class CreateMemberCommissionUser extends Usecase<MemberCommission, CreateMemberCommissionParams> {
  final MemberAdminRepository repository;
  CreateMemberCommissionUser({required this.repository});

  @override
  Future<Either<Failure, MemberCommission>> call(CreateMemberCommissionParams params) {
    if (params.commissionPercent < 0 || params.commissionPercent > 100) {
      return Future.value(const Left(ServerFailure('Commission percent must be between 0 and 100')));
    }
    return repository.createMemberCommission(
      businessMemberId: params.businessMemberId,
      packageId: params.packageId,
      commissionPercent: params.commissionPercent,
      effectiveFrom: params.effectiveFrom,
    );
  }
}