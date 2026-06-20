import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package_category.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class GetPackageCategoriesForBusiness extends Usecase<List<PackageCategory>, GetPackageCategoriesForBusinessParams> {
  final PackageRepository repository;

  GetPackageCategoriesForBusiness({required this.repository});

  @override
  Future<Either<Failure, List<PackageCategory>>> call(GetPackageCategoriesForBusinessParams params) {
    return repository.getPackageCategoriesForBusiness(params.businessId);
  }
}
