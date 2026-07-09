
import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/entities/member_commission.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';

class GetBusinessCommissionsUser extends Usecase<void, GetBusinessByIdParams> {
  final MemberAdminRepository repository;
  GetBusinessCommissionsUser({required this.repository});

  @override
  Future<Either<Failure, List<MemberCommission>>> call(GetBusinessByIdParams params) {
    return repository.getBusinessCommissions( businessId: params.businessId );
  }
}