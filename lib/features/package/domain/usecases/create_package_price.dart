import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package_price.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class CreatePackagePrice extends Usecase<PackagePrice, CreatePackagePriceParams> {
  final PackageRepository repository;

  CreatePackagePrice({required this.repository});

  @override
  Future<Either<Failure, PackagePrice>> call(CreatePackagePriceParams params) {
    return repository.createPackagePrice(
      packageId: params.packageId,
      totalPrice: params.totalPrice,
      depositAmount: params.depositAmount,
      remainingAmount: params.remainingAmount,
      isPersonal: params.isPersonal,
      effectiveFrom: params.effectiveFrom,
    );
  }
}
