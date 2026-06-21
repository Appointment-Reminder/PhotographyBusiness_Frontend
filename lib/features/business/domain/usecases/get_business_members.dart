import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_member_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';

import '../repositories/business_repository.dart';

class GetBusinessMembersUser extends Usecase<List<BusinessMember>, GetBusinessMembersParams>{
  final BusinessMemberRepository repository;

  GetBusinessMembersUser({required this.repository});

  @override
  Future<Either<Failure, List<BusinessMember>>> call(GetBusinessMembersParams params) {
    return repository.getBusinessMembers(params.businessId);
  }
}