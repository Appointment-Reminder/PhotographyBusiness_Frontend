
import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_repository.dart';

import '../entities/business_member.dart';
import 'business_params.dart';

class InviteMemberUser extends Usecase<BusinessMember, InviteMemberParams>{
  final BusinessRepository repository;

  InviteMemberUser({required this.repository});

  @override
  Future<Either<Failure, BusinessMember>> call(InviteMemberParams params) {
    if(params.userEmail.isEmpty){
      return Future.value(
        Left(ServerFailure('Email is required')),
      );
    }
    if(params.role.isEmpty){
      return Future.value(
        Left(ServerFailure('Role is required'))
      );
    }

    return repository.inviteMember(
        businessId: params.businessId,
        userEmail: params.userEmail,
        role: params.role
    );
  }
}