import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import '../entities/package_price.dart';
import '../repositories/package_repository.dart';
import 'package_params.dart';

class GetPackagePriceHistory extends Usecase<List<PackagePrice>, GetPackagePriceHistoryParams> {
  final PackageRepository repository;

  GetPackagePriceHistory({required this.repository});

  @override
  Future<Either<Failure, List<PackagePrice>>> call(GetPackagePriceHistoryParams params) {
    return repository.getPackagePriceHistory(params.packageId);
  }
}
