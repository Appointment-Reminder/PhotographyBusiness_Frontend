import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';

class DeleteBusinessUser extends Usecase<void, DeleteBusinessParams> {

  final BusinessRepository repository;

  DeleteBusinessUser({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeleteBusinessParams params) {
    return repository.deleteBusiness(params.businessId);
  }
}