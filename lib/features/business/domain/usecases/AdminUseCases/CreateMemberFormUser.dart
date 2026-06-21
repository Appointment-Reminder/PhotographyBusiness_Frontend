import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member_form.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/member_params.dart';

class CreateMemberFormUser extends Usecase<BusinessMemberForm, CreateMemberFormParams> {
  final MemberAdminRepository repository;
  CreateMemberFormUser({required this.repository});

  @override
  Future<Either<Failure, BusinessMemberForm>> call(CreateMemberFormParams params) {
    if (params.jotformFieldMap.isEmpty) {
      return Future.value(const Left(ServerFailure('Field map is required')));
    }
    return repository.createMemberForm(
      businessMemberId: params.businessMemberId,
      categoryId: params.categoryId,
      jotformFieldMap: params.jotformFieldMap,
    );
  }
}