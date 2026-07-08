import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/member_params.dart';

class UpdateMemberCommissionUser extends Usecase<MemberCommission, UpdateMemberCommissionParams>{
  final MemberAdminRepository repository;

  UpdateMemberCommissionUser({required this.repository});

  @override
  Future<Either<Failure, MemberCommission>> call(UpdateMemberCommissionParams params) {
    return repository.updateMemberCommission(
        id: params.id,
        commissionAmount: params.commissionAmount,
        commissionIsPercent: params.commissionIsPercentage);
  }

}