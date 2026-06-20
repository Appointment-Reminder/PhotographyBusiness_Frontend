import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class GetPackageById extends Usecase<Package, GetPackageByIdParams> {
  final PackageRepository repository;

  GetPackageById({required this.repository});

  @override
  Future<Either<Failure, Package>> call(GetPackageByIdParams params) {
    return repository.getPackageById(params.packageId);
  }
}
