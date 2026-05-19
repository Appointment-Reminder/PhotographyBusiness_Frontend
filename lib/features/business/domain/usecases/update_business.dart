import 'package:dartz/dartz.dart';

import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_repository.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/business.dart';
import 'business_params.dart';

class UpdateBusiness extends Usecase<Business, UpdateBusinessParams>{
  final BusinessRepository repository;

  UpdateBusiness({required this.repository});

  @override
  Future<Either<Failure, Business>> call(UpdateBusinessParams params) {
    if(params.name == null && params.description == null){
      return Future.value(Left(ServerFailure('At least one field must be provided')));
    }

    return repository.updateBusiness(
        businessId: params.businessId,
        name: params.name,
        description: params.description,
    );
  }
}