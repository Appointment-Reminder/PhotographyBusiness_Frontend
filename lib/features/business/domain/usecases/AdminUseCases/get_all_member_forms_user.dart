

import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member_form.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';

class GetAllMemberFormsUser extends Usecase<void, GetBusinessByIdParams>{
  final MemberAdminRepository repository;

  GetAllMemberFormsUser({required this.repository});

  @override
  Future<Either<Failure, List<BusinessMemberForm>>> call(GetBusinessByIdParams params) {
    return repository.getAllMemberForms(businessId: params.businessId);
  }

}