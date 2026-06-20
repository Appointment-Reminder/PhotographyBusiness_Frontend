import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class CreatePackage extends Usecase<Package, CreatePackageParams> {
  final PackageRepository repository;

  CreatePackage({required this.repository});

  @override
  Future<Either<Failure, Package>> call(CreatePackageParams params) {
    if (params.name.isEmpty) {
      return Future.value(const Left(ServerFailure('Package name is required')));
    }

    return repository.createPackage(
      name: params.name,
      description: params.description,
      businessId: params.businessId,
      categoryId: params.categoryId,
    );
  }
}
