import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package_category.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class CreatePackageCategory extends Usecase<PackageCategory, CreatePackageCategoryParams> {
  final PackageRepository repository;

  CreatePackageCategory({required this.repository});

  @override
  Future<Either<Failure, PackageCategory>> call(CreatePackageCategoryParams params) {
    if (params.name.isEmpty) {
      return Future.value(const Left(ServerFailure('Category name is required')));
    }

    return repository.createPackageCategory(
      businessId: params.businessId,
      name: params.name,
    );
  }
}
