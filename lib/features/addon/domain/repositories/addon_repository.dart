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

  /// The Member's commission in effect now on every active Add-on, a flat 0
  /// (null id) where there is none. Owner and admin only.
  Future<Either<Failure, List<AddonCommission>>> listMemberAddonCommissions({
    required int businessId,
    required int memberId,
  });

  /// Corrects the commission version [id] in place, without a new dated version.
  Future<Either<Failure, AddonCommission>> updateAddonCommission({
    required int id,
    required int commissionAmount,
    required bool commissionIsPercentage,
  });

  Future<Either<Failure, AddonCommission>> createAddonCommission({
    required int memberId,
    required int addonId,
    required int commissionAmount,
    required bool commissionIsPercentage,
    required DateTime effectiveFrom,
  });
}
