import 'package:dio/dio.dart';
import 'package:photography_business_frontend/features/package/data/datasources/package_remote_datasource.dart';
import 'package:photography_business_frontend/features/package/data/models/package_category_model.dart';
import 'package:photography_business_frontend/features/package/data/models/package_model.dart';
import 'package:photography_business_frontend/features/package/data/models/package_price_model.dart';
import '../../domain/entities/package.dart';
import '../../domain/entities/package_category.dart';
import '../../domain/entities/package_price.dart';

class PackageRemoteDatasourceImpl implements PackageRemoteDatasource {
  final Dio client;

  PackageRemoteDatasourceImpl({required this.client});

  @override
  Future<Package> createPackage({
    required String name,
    required String description,
    required int businessId,
    required int categoryId,
  }) async {
    final response = await client.post(
      '/business/packages',
      data: {
        'name': name,
        'description': description,
        'business_id': businessId,
        'category_id': categoryId,
      },
    );

    return PackageModel.fromJson(response.data);
  }

  @override
  Future<Package> updatePackage({
    required int id,
    required int businessId,
    required int categoryId,
    required String name,
    required String description,
  }) async {
    final response = await client.put(
      '/business/packages',
      data: {
        'id': id,
        'business_id': businessId,
        'category_id': categoryId,
        'name': name,
        'description': description,
      },
    );

    return PackageModel.fromJson(response.data);
  }

  @override
  Future<List<Package>> getPackagesForBusiness(int businessId) async {
    final response = await client.get('/business/$businessId/packages');

    final List<dynamic> packageList = response.data;
    return packageList.map((json) => PackageModel.fromJson(json)).toList();
  }

  @override
  Future<Package> getPackageById(int packageId) async {
    final response = await client.get('/business/packages/$packageId');

    return PackageModel.fromJson(response.data);
  }

  @override
  Future<void> deletePackage(int packageId) async {
    await client.delete('/business/packages/$packageId');
  }

  @override
  Future<PackageCategory> createPackageCategory({
    required int businessId,
    required String name,
  }) async {
    final response = await client.post(
      '/business/categories',
      data: {
        'business_id': businessId,
        'name': name,
      },
    );

    return PackageCategoryModel.fromJson(response.data);
  }

  @override
  Future<List<PackageCategory>> getPackageCategoriesForBusiness(int businessId) async {
    final response = await client.get('/business/$businessId/categories');

    final List<dynamic> categoryList = response.data;
    return categoryList.map((json) => PackageCategoryModel.fromJson(json)).toList();
  }

  @override
  Future<void> deletePackageCategory(int categoryId) async {
    await client.delete('/business/categories/$categoryId');
  }

  @override
  Future<PackagePrice> createPackagePrice({
    required int packageId,
    required int totalPrice,
    required int depositAmount,
    required int remainingAmount,
    required bool isPersonal,
    required DateTime effectiveFrom,
  }) async {
    final response = await client.post(
      '/business/packages/prices',
      data: {
        'package_id': packageId,
        'total_price': totalPrice,
        'deposit_amount': depositAmount,
        'remaining_amount': remainingAmount,
        'is_personal': isPersonal,
        'effective_from': effectiveFrom.toIso8601String(),
      },
    );

    return PackagePriceModel.fromJson(response.data);
  }

  @override
  Future<List<PackagePrice>> getPackagePriceHistory(int packageId) async {
    final response = await client.get('/business/packages/$packageId/prices');

    final List<dynamic> priceList = response.data;
    return priceList.map((json) => PackagePriceModel.fromJson(json)).toList();
  }

  @override
  Future<PackagePrice> getCurrentPackagePrice(int packageId) async {
    final response = await client.get('/business/packages/$packageId/prices/current');

    return PackagePriceModel.fromJson(response.data);
  }
}
