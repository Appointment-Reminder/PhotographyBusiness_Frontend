import 'package:equatable/equatable.dart';

class AddonPrice extends Equatable {
  final int id;
  final int addonId;
  final int price;
  final DateTime effectiveFrom;

  const AddonPrice({
    required this.id,
    required this.addonId,
    required this.price,
    required this.effectiveFrom,
  });

  /// Newest first.
  static List<AddonPrice> newestFirst(Iterable<AddonPrice> prices) =>
      [...prices]..sort((a, b) => b.effectiveFrom.compareTo(a.effectiveFrom));

  /// The price in effect at [now]: the newest one that has already started.
  /// A future-dated price is never current.
  static AddonPrice? currentOf(Iterable<AddonPrice> prices, DateTime now) {
    for (final p in newestFirst(prices)) {
      if (!p.effectiveFrom.isAfter(now)) return p;
    }
    return null;
  }

  @override
  List<Object?> get props => [id, addonId, price, effectiveFrom];
}
