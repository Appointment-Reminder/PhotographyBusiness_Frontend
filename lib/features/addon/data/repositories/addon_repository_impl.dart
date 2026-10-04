import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import '../../domain/entities/addon.dart';
import '../../domain/entities/addon_commission.dart';
import '../../domain/entities/addon_price.dart';
import '../../domain/repositories/addon_repository.dart';
import '../datasources/addon_remote_datasource.dart';

class AddonRepositoryImpl implements AddonRepository {
  final AddonRemoteDatasource remote;
  final NetworkInfo networkInfo;

  AddonRepositoryImpl({required this.remote, required this.networkInfo});

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure('No internet connection'));
      }
      return Right(await action());
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<Addon>>> getAddons(int businessId) =>
      _execute(() => remote.getAddons(businessId));

  @override
  Future<Either<Failure, Addon>> createAddon({
    required int businessId,
    required String name,
    required String jotformAlias,
    required bool hasDuration,
    required int? durationMinutes,
    required bool hasQuantity,
  }) =>
      _execute(() => remote.createAddon(
            businessId: businessId,
            name: name,
            jotformAlias: jotformAlias,
            hasDuration: hasDuration,
            durationMinutes: durationMinutes,
            hasQuantity: hasQuantity,
          ));

  @override
  Future<Either<Failure, Addon>> updateAddon(Addon addon) =>
      _execute(() => remote.updateAddon(addon));

  @override
  Future<Either<Failure, Addon>> deactivateAddon(int addonId) =>
      _execute(() => remote.deactivateAddon(addonId));

  @override
  Future<Either<Failure, AddonPrice>> createAddonPrice({
    required int addonId,
    required int price,
    required DateTime effectiveFrom,
  }) =>
      _execute(() => remote.createAddonPrice(
          addonId: addonId, price: price, effectiveFrom: effectiveFrom));

  @override
  Future<Either<Failure, List<AddonPrice>>> getAddonPriceHistory(int addonId) =>
      _execute(() => remote.getAddonPriceHistory(addonId));

  @override
  Future<Either<Failure, AddonPrice>> getCurrentAddonPrice(int addonId) =>
      _execute(() => remote.getCurrentAddonPrice(addonId));

  @override
  Future<Either<Failure, AddonCommission>> getMemberAddonCommission({
    required int addonId,
    required int memberId,
  }) =>
      _execute(() => remote.getMemberAddonCommission(addonId: addonId, memberId: memberId));

  @override
  Future<Either<Failure, AddonCommission>> createAddonCommission({
    required int memberId,
    required int addonId,
    required int commissionAmount,
    required bool commissionIsPercentage,
    required DateTime effectiveFrom,
  }) =>
      _execute(() => remote.createAddonCommission(
            memberId: memberId,
            addonId: addonId,
            commissionAmount: commissionAmount,
            commissionIsPercentage: commissionIsPercentage,
            effectiveFrom: effectiveFrom,
          ));
}
