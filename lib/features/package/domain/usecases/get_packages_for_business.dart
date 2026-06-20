import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class GetPackagesForBusiness extends Usecase<List<Package>, GetPackagesForBusinessParams> {
  final PackageRepository repository;

  GetPackagesForBusiness({required this.repository});

  @override
  Future<Either<Failure, List<Package>>> call(GetPackagesForBusinessParams params) {
    return repository.getPackagesForBusiness(params.businessId);
  }
}
