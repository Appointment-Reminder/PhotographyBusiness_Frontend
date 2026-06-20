import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class DeletePackageCategory extends Usecase<void, DeletePackageCategoryParams> {
  final PackageRepository repository;

  DeletePackageCategory({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeletePackageCategoryParams params) {
    return repository.deletePackageCategory(params.categoryId);
  }
}
