import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_member_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/business_member.dart';
import '../repositories/business_repository.dart';

class UpdateMemberRoleUser extends Usecase<BusinessMember, UpdateMemberRoleParams>{
  final BusinessMemberRepository repository;

  UpdateMemberRoleUser({required this.repository});

  @override
  Future<Either<Failure, BusinessMember>> call(UpdateMemberRoleParams params) {
    if(params.role.isEmpty){
      return Future.value(
        Left(ServerFailure('Role is required'))
      );
    }

    return repository.updateMemberRole(
      businessId: params.businessId,
      memberId: params.memberId,
      role: params.role,
      isActive: params.isActive,
    );
  }
}