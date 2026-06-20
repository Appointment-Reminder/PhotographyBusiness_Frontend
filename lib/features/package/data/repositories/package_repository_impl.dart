import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import 'package:photography_business_frontend/features/package/data/datasources/package_remote_datasource.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_category.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_price.dart';
import 'package:photography_business_frontend/features/package/domain/repositories/package_repository.dart';

class PackageRepositoryImpl implements PackageRepository {
  final PackageRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  PackageRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure('No internet connection'));
      }
      final result = await action();
      return Right(result);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Package>> createPackage({
    required String name,
    required String description,
    required int businessId,
    required int categoryId,
  }) {
    return _execute(() => remoteDatasource.createPackage(
          name: name,
          description: description,
          businessId: businessId,
          categoryId: categoryId,
        ));
  }

  @override
  Future<Either<Failure, Package>> updatePackage({
    required int id,
    required int businessId,
    required int categoryId,
    required String name,
    required String description,
  }) {
    return _execute(() => remoteDatasource.updatePackage(
          id: id,
          businessId: businessId,
          categoryId: categoryId,
          name: name,
          description: description,
        ));
  }

  @override
  Future<Either<Failure, List<Package>>> getPackagesForBusiness(int businessId) {
    return _execute(() => remoteDatasource.getPackagesForBusiness(businessId));
  }

  @override
  Future<Either<Failure, Package>> getPackageById(int packageId) {
    return _execute(() => remoteDatasource.getPackageById(packageId));
  }

  @override
  Future<Either<Failure, void>> deletePackage(int packageId) {
    return _execute(() => remoteDatasource.deletePackage(packageId));
  }

  @override
  Future<Either<Failure, PackageCategory>> createPackageCategory({
    required int businessId,
    required String name,
  }) {
    return _execute(() => remoteDatasource.createPackageCategory(
          businessId: businessId,
          name: name,
        ));
  }

  @override
  Future<Either<Failure, List<PackageCategory>>> getPackageCategoriesForBusiness(int businessId) {
    return _execute(() => remoteDatasource.getPackageCategoriesForBusiness(businessId));
  }

  @override
  Future<Either<Failure, void>> deletePackageCategory(int categoryId) {
    return _execute(() => remoteDatasource.deletePackageCategory(categoryId));
  }

  @override
  Future<Either<Failure, PackagePrice>> createPackagePrice({
    required int packageId,
    required int totalPrice,
    required int depositAmount,
    required int remainingAmount,
    required bool isPersonal,
    required DateTime effectiveFrom,
  }) {
    return _execute(() => remoteDatasource.createPackagePrice(
          packageId: packageId,
          totalPrice: totalPrice,
          depositAmount: depositAmount,
          remainingAmount: remainingAmount,
          isPersonal: isPersonal,
          effectiveFrom: effectiveFrom,
        ));
  }

  @override
  Future<Either<Failure, List<PackagePrice>>> getPackagePriceHistory(int packageId) {
    return _execute(() => remoteDatasource.getPackagePriceHistory(packageId));
  }

  @override
  Future<Either<Failure, PackagePrice>> getCurrentPackagePrice(int packageId) {
    return _execute(() => remoteDatasource.getCurrentPackagePrice(packageId));
  }
}
