import 'package:equatable/equatable.dart';
import '../../../domain/entities/addon.dart';
import '../../../domain/entities/addon_price.dart';

/// The first price of a just-created Add-on that could not be saved, kept so
/// only the price step is retried.
class PendingAddonPrice extends Equatable {
  final int addonId;
  final int price;
  final DateTime effectiveFrom;

  const PendingAddonPrice({
    required this.addonId,
    required this.price,
    required this.effectiveFrom,
  });

  @override
  List<Object?> get props => [addonId, price, effectiveFrom];
}

class AddonCatalogState extends Equatable {
  final List<Addon> addons;

  final int? selectedId;

  /// Price history of the selected Add-on, newest first.
  final List<AddonPrice> history;
  final PendingAddonPrice? pendingPrice;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const AddonCatalogState({
    this.addons = const [],
    this.selectedId,
    this.history = const [],
    this.pendingPrice,
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  Addon? get selected {
    for (final a in addons) {
      if (a.id == selectedId) return a;
    }
    return null;
  }

  /// addonId -> price in effect now. Absent when the Add-on has none.
  Map<int, int> get currentPrices => {
        for (final a in addons)
          if (a.currentPrice != null) a.id: a.currentPrice!,
      };

  bool get hasPendingPrice => pendingPrice != null;

  /// Id of the history entry that is in effect now (never a future-dated one).
  int? get currentHistoryPriceId => AddonPrice.currentOf(history, DateTime.now())?.id;

  AddonCatalogState copyWith({
    List<Addon>? addons,
    int? selectedId,
    List<AddonPrice>? history,
    PendingAddonPrice? pendingPrice,
    bool clearPendingPrice = false,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
  }) =>
      AddonCatalogState(
        addons: addons ?? this.addons,
        selectedId: selectedId ?? this.selectedId,
        history: history ?? this.history,
        pendingPrice: clearPendingPrice ? null : (pendingPrice ?? this.pendingPrice),
        isLoading: isLoading ?? this.isLoading,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        error: error,
      );

  @override
  List<Object?> get props =>
      [addons, selectedId, history, pendingPrice, isLoading, isSubmitting, error];
}
