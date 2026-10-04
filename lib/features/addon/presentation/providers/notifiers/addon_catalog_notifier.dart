import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/addon.dart';
import '../../../domain/entities/addon_price.dart';
import '../../../domain/repositories/addon_repository.dart';
import '../state/addon_catalog_state.dart';

class AddonCatalogNotifier extends StateNotifier<AddonCatalogState> {
  final AddonRepository repository;

  AddonCatalogNotifier({required this.repository}) : super(const AddonCatalogState());

  Future<void> load(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.getAddons(businessId);
    await result.fold(
      (f) async => state = state.copyWith(isLoading: false, error: f.message),
      (addons) async => state = state.copyWith(isLoading: false, addons: addons),
    );
  }

  Future<void> select(int addonId) async {
    state = state.copyWith(selectedId: addonId, history: const [], error: null);
    await _loadHistory(addonId);
  }

  Future<void> _loadHistory(int addonId) async {
    final result = await repository.getAddonPriceHistory(addonId);
    if (state.selectedId != addonId) return;
    result.fold(
      (f) => state = state.copyWith(error: f.message),
      (prices) => state = state.copyWith(history: AddonPrice.newestFirst(prices)),
    );
  }

  /// Creates the Add-on, then its first price. If the price step fails the
  /// Add-on stays, and [retryPrice] posts only the price. Returns whether
  /// both steps succeeded.
  Future<bool> create({
    required int businessId,
    required String name,
    required String jotformAlias,
    required bool hasDuration,
    required int? durationMinutes,
    required bool hasQuantity,
    required int price,
    required DateTime effectiveFrom,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final created = await repository.createAddon(
      businessId: businessId,
      name: name,
      jotformAlias: jotformAlias,
      hasDuration: hasDuration,
      durationMinutes: hasDuration ? durationMinutes : null,
      hasQuantity: hasQuantity,
    );
    return created.fold<Future<bool>>((f) async {
      state = state.copyWith(isSubmitting: false, error: f.message);
      return false;
    }, (addon) async {
      state = state.copyWith(addons: [...state.addons, addon], selectedId: addon.id, history: const []);
      final pending = PendingAddonPrice(addonId: addon.id, price: price, effectiveFrom: effectiveFrom);
      return _postPrice(pending);
    });
  }

  Future<bool> retryPrice() async {
    final pending = state.pendingPrice;
    if (pending == null) return false;
    state = state.copyWith(isSubmitting: true, error: null);
    return _postPrice(pending);
  }

  Future<bool> _postPrice(PendingAddonPrice p) async {
    final result = await repository.createAddonPrice(
      addonId: p.addonId,
      price: p.price,
      effectiveFrom: p.effectiveFrom,
    );
    return result.fold<Future<bool>>((f) async {
      state = state.copyWith(isSubmitting: false, pendingPrice: p, error: f.message);
      return false;
    }, (_) async {
      state = state.copyWith(isSubmitting: false, clearPendingPrice: true);
      await _refreshPrices(p.addonId);
      return true;
    });
  }

  /// Re-reads the list, which carries each Add-on's price in effect now, and
  /// the history of [addonId] if it is selected.
  Future<void> _refreshPrices(int addonId) async {
    final addon = _byId(addonId);
    if (addon != null) {
      final listed = await repository.getAddons(addon.businessId);
      listed.fold((_) {}, (addons) => state = state.copyWith(addons: addons));
    }
    if (state.selectedId == addonId) await _loadHistory(addonId);
  }

  Future<bool> addPrice({
    required int addonId,
    required int price,
    required DateTime effectiveFrom,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    return _postPrice(PendingAddonPrice(addonId: addonId, price: price, effectiveFrom: effectiveFrom))
        .then((ok) {
      // A failed new price on an existing Add-on is not a half-created Add-on.
      if (!ok) state = state.copyWith(clearPendingPrice: true, error: state.error);
      return ok;
    });
  }

  Future<bool> update({
    required int addonId,
    required String name,
    required String jotformAlias,
    required bool hasDuration,
    required int? durationMinutes,
    required bool hasQuantity,
  }) {
    final current = _byId(addonId);
    if (current == null) return Future.value(false);
    return _save(current.copyWith(
      name: name,
      jotformAlias: jotformAlias,
      hasDuration: hasDuration,
      durationMinutes: durationMinutes,
      hasQuantity: hasQuantity,
    ));
  }

  /// Deactivate has its own endpoint; reactivating is an update with the
  /// active flag on.
  Future<bool> setActive(int addonId, bool active) async {
    final current = _byId(addonId);
    if (current == null) return false;
    if (active) return _save(current.copyWith(isActive: true));
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await repository.deactivateAddon(addonId);
    return result.fold((f) {
      state = state.copyWith(isSubmitting: false, error: f.message);
      return false;
    }, (updated) {
      _replace(updated);
      return true;
    });
  }

  Future<bool> _save(Addon addon) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final result = await repository.updateAddon(addon);
    return result.fold((f) {
      state = state.copyWith(isSubmitting: false, error: f.message);
      return false;
    }, (updated) {
      _replace(updated);
      return true;
    });
  }

  void _replace(Addon updated) {
    state = state.copyWith(
      isSubmitting: false,
      addons: [for (final a in state.addons) a.id == updated.id ? updated : a],
    );
  }

  Addon? _byId(int id) {
    for (final a in state.addons) {
      if (a.id == id) return a;
    }
    return null;
  }
}
