import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';

import '../../../../core/error/failure.dart';
import '../entities/business.dart';
import '../repositories/business_repository.dart';

class GetMyBusinessesUser extends Usecase<List<Business>, GetMyBusinessesParams>{
  final BusinessRepository repository;

  GetMyBusinessesUser({required this.repository});

  @override
  Future<Either<Failure, List<Business>>> call(GetMyBusinessesParams params) async {
    return await repository.getMyBusinesses(isActive: params.isActive);
  }
}