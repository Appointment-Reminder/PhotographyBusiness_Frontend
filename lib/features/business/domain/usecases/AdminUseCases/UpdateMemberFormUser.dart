import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';

import '../../../../../core/error/failure.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../entities/business_member_form.dart';
import '../member_params.dart';

class UpdateMemberFormUser extends Usecase<BusinessMemberForm, UpdateMemberFormParams> {
  final MemberAdminRepository repository;
  UpdateMemberFormUser({required this.repository});

  @override
  Future<Either<Failure, BusinessMemberForm>> call(UpdateMemberFormParams params) {
    if (params.jotformFieldMap.isEmpty) {
      return Future.value(const Left(ServerFailure('Field map is required')));
    }
    return repository.updateMemberForm(
      id: params.id,
      businessMemberId: params.businessMemberId,
      categoryId: params.categoryId,
      jotformFieldMap: params.jotformFieldMap,
    );
  }
}