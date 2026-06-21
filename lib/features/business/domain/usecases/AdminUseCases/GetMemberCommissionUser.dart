// get_member_commission.dart
import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';

import '../../../../../core/usecases/usecase.dart';
import '../../entities/member_commission.dart';
import '../member_params.dart';

class GetMemberCommissionUser extends Usecase<MemberCommission, GetMemberCommissionParams> {
  final MemberAdminRepository repository;
  GetMemberCommissionUser({required this.repository});

  @override
  Future<Either<Failure, MemberCommission>> call(GetMemberCommissionParams params) {
    return repository.getMemberCommission(memberId: params.memberId, packageId: params.packageId);
  }
}