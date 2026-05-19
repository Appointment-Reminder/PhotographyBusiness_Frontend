import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';

import '../../../../core/usecases/usecase.dart';
import '../repositories/business_repository.dart';

class RemoveMember extends Usecase<void, RemoveMemberParams>{
  final BusinessRepository repository;

  RemoveMember({required this.repository});

  @override
  Future<Either<Failure, void>> call(RemoveMemberParams params) {
    return repository.removeMember(
      businessId: params.businessId,
      memberId: params.memberId,
    );
  }
}