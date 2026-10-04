import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/addon.dart';
import '../entities/addon_commission.dart';
import '../entities/addon_price.dart';

abstract class AddonRepository {
  Future<Either<Failure, List<Addon>>> getAddons(int businessId);

  /// The category is always sent as null: the app does not manage categories.
  Future<Either<Failure, Addon>> createAddon({
    required int businessId,
    required String name,
    required String jotformAlias,
    required bool hasDuration,
    required int? durationMinutes,
    required bool hasQuantity,
  });

  /// Sends every field of [addon], including its existing category.
  Future<Either<Failure, Addon>> updateAddon(Addon addon);

  Future<Either<Failure, Addon>> deactivateAddon(int addonId);

  Future<Either<Failure, AddonPrice>> createAddonPrice({
    required int addonId,
    required int price,
    required DateTime effectiveFrom,
  });

  Future<Either<Failure, List<AddonPrice>>> getAddonPriceHistory(int addonId);

  /// Fails when the Add-on has no price in effect (the backend answers 400).
  Future<Either<Failure, AddonPrice>> getCurrentAddonPrice(int addonId);

  Future<Either<Failure, AddonCommission>> getMemberAddonCommission({
    required int addonId,
    required int memberId,
  });

  Future<Either<Failure, AddonCommission>> createAddonCommission({
    required int memberId,
    required int addonId,
    required int commissionAmount,
    required bool commissionIsPercentage,
    required DateTime effectiveFrom,
  });
}
