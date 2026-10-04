import '../../domain/entities/addon.dart';
import '../../domain/entities/addon_commission.dart';
import '../../domain/entities/addon_price.dart';

Addon addonFromJson(Map<String, dynamic> j) => Addon(
      id: j['id'],
      businessId: j['business_id'],
      name: j['name'],
      jotformAlias: j['jotform_alias'],
      isActive: j['is_active'],
      categoryId: j['category_id'],
      hasDuration: j['has_duration'],
      hasQuantity: j['has_quantity'],
      durationMinutes: j['duration_minutes'],
    );

AddonPrice addonPriceFromJson(Map<String, dynamic> j) => AddonPrice(
      id: j['id'],
      addonId: j['addon_id'],
      price: j['price'],
      effectiveFrom: DateTime.parse(j['effective_from']),
    );

AddonCommission addonCommissionFromJson(Map<String, dynamic> j) => AddonCommission(
      id: j['id'],
      businessMemberId: j['business_member_id'],
      addonId: j['addon_id'],
      commissionAmount: j['commission_amount'],
      commissionIsPercentage: j['commission_isPercentage'],
      effectiveFrom: DateTime.parse(j['effective_from']),
    );
