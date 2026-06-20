import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class UpdatePackage extends Usecase<Package, UpdatePackageParams> {
  final PackageRepository repository;

  UpdatePackage({required this.repository});

  @override
  Future<Either<Failure, Package>> call(UpdatePackageParams params) {
    if (params.name.isEmpty) {
      return Future.value(const Left(ServerFailure('Package name is required')));
    }

    return repository.updatePackage(
      id: params.id,
      businessId: params.businessId,
      categoryId: params.categoryId,
      name: params.name,
      description: params.description,
    );
  }
}
