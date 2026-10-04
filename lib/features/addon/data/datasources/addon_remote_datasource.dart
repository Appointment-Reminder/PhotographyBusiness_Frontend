import 'package:dio/dio.dart';
import '../../domain/entities/addon.dart';
import '../../domain/entities/addon_commission.dart';
import '../../domain/entities/addon_price.dart';
import '../models/addon_models.dart';

class AddonRemoteDatasource {
  final Dio client;
  AddonRemoteDatasource({required this.client});

  Future<List<Addon>> getAddons(int businessId) async {
    final r = await client.get('/business/$businessId/addons');
    return [for (final j in r.data as List) addonFromJson(j)];
  }

  Future<Addon> createAddon({
    required int businessId,
    required String name,
    required String jotformAlias,
    required bool hasDuration,
    required int? durationMinutes,
    required bool hasQuantity,
  }) async {
    final r = await client.post('/business/addons', data: {
      'business_id': businessId,
      'name': name,
      'jotform_alias': jotformAlias,
      'category_id': null,
      'has_duration': hasDuration,
      'has_quantity': hasQuantity,
      'duration_minutes': durationMinutes,
    });
    return addonFromJson(r.data);
  }

  Future<Addon> updateAddon(Addon a) async {
    final r = await client.put('/business/addons/${a.id}', data: {
      'name': a.name,
      'jotform_alias': a.jotformAlias,
      'is_active': a.isActive,
      'category_id': a.categoryId,
      'has_duration': a.hasDuration,
      'has_quantity': a.hasQuantity,
      'duration_minutes': a.durationMinutes,
    });
    return addonFromJson(r.data);
  }

  Future<Addon> deactivateAddon(int addonId) async {
    final r = await client.post('/business/addons/$addonId/deactivate');
    return addonFromJson(r.data);
  }

  Future<AddonPrice> createAddonPrice({
    required int addonId,
    required int price,
    required DateTime effectiveFrom,
  }) async {
    final r = await client.post('/business/addons/prices', data: {
      'addon_id': addonId,
      'price': price,
      'effective_from': effectiveFrom.toIso8601String(),
    });
    return addonPriceFromJson(r.data);
  }

  Future<List<AddonPrice>> getAddonPriceHistory(int addonId) async {
    final r = await client.get('/business/addons/$addonId/prices');
    return [for (final j in r.data as List) addonPriceFromJson(j)];
  }

  Future<AddonPrice> getCurrentAddonPrice(int addonId) async {
    final r = await client.get('/business/addons/$addonId/prices/current');
    return addonPriceFromJson(r.data);
  }

  Future<AddonCommission> getMemberAddonCommission({
    required int addonId,
    required int memberId,
  }) async {
    final r = await client.get('/business/addons/$addonId/members/$memberId/commission');
    return addonCommissionFromJson(r.data);
  }

  Future<AddonCommission> createAddonCommission({
    required int memberId,
    required int addonId,
    required int commissionAmount,
    required bool commissionIsPercentage,
    required DateTime effectiveFrom,
  }) async {
    final r = await client.post('/business/addons/commissions', data: {
      'business_member_id': memberId,
      'addon_id': addonId,
      'commission_amount': commissionAmount,
      'commission_isPercentage': commissionIsPercentage,
      'effective_from': effectiveFrom.toIso8601String(),
    });
    return addonCommissionFromJson(r.data);
  }
}
