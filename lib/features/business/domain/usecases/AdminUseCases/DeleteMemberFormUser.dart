import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/member_params.dart';

class DeleteMemberFormUser extends Usecase<void, DeleteMemberFormParams> {
  final MemberAdminRepository repository;
  DeleteMemberFormUser({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteMemberFormParams params) {
    return repository.deleteMemberForm(params.formId);
  }
}