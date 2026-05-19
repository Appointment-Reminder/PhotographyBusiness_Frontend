import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';

import '../entities/business.dart';
import '../repositories/business_repository.dart';
import 'business_params.dart';

class CreateBusiness extends Usecase<Business, CreateBusinessParams> {
  final BusinessRepository repository;

  CreateBusiness({required this.repository});

  @override
  Future<Either<Failure, Business>> call(CreateBusinessParams params) {
    if(params.name.isEmpty){
      return Future.value(
        Left(ServerFailure('Business name is required')),
      );
    }

    return repository.createBusiness(
      name: params.name,
      description: params.description,
    );
  }
}