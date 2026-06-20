import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package_price.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class GetCurrentPackagePrice extends Usecase<PackagePrice, GetCurrentPackagePriceParams> {
  final PackageRepository repository;

  GetCurrentPackagePrice({required this.repository});

  @override
  Future<Either<Failure, PackagePrice>> call(GetCurrentPackagePriceParams params) {
    return repository.getCurrentPackagePrice(params.packageId);
  }
}
