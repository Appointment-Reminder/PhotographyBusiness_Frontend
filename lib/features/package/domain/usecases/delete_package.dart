import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class DeletePackage extends Usecase<void, DeletePackageParams> {
  final PackageRepository repository;

  DeletePackage({required this.repository});

  @override
  Future<Either<Failure, void>> call(DeletePackageParams params) {
    return repository.deletePackage(params.packageId);
  }
}
