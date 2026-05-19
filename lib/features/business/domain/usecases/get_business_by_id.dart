import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';

import '../../../../core/error/failure.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';
import 'business_params.dart';

class GetBusinessById extends Usecase<Business, GetBusinessByIdParams> {
  final BusinessRepository repository;

  GetBusinessById(this.repository);

  @override
  Future<Either<Failure, Business>> call(GetBusinessByIdParams params) async {
    return await repository.getBusinessById(params.businessId);
  }
}