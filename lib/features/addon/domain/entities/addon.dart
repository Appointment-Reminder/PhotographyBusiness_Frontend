import 'package:equatable/equatable.dart';

/// Mirrors AddonRead. `categoryId` is never shown or edited by the app, only
/// carried so an update sends it back untouched.
class Addon extends Equatable {
  final int id;
  final int businessId;
  final String name;
  final String jotformAlias;
  final bool isActive;
  final int? categoryId;
  final bool hasDuration;
  final bool hasQuantity;
  final int? durationMinutes;

  /// The price in effect now, in whole euros; null when it has none. Read-only:
  /// it comes with the listing and is never sent back on an update.
  final int? currentPrice;

  const Addon({
    required this.id,
    required this.businessId,
    required this.name,
    required this.jotformAlias,
    required this.isActive,
    this.categoryId,
    required this.hasDuration,
    required this.hasQuantity,
    this.durationMinutes,
    this.currentPrice,
  });

  Addon copyWith({
    String? name,
    String? jotformAlias,
    bool? isActive,
    bool? hasDuration,
    bool? hasQuantity,
    int? durationMinutes,
  }) {
    final duration = hasDuration ?? this.hasDuration;
    return Addon(
      id: id,
      businessId: businessId,
      name: name ?? this.name,
      jotformAlias: jotformAlias ?? this.jotformAlias,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId,
      hasDuration: duration,
      hasQuantity: hasQuantity ?? this.hasQuantity,
      durationMinutes: duration ? (durationMinutes ?? this.durationMinutes) : null,
      currentPrice: currentPrice,
    );
  }

  Addon withCurrentPrice(int? price) => Addon(
        id: id,
        businessId: businessId,
        name: name,
        jotformAlias: jotformAlias,
        isActive: isActive,
        categoryId: categoryId,
        hasDuration: hasDuration,
        hasQuantity: hasQuantity,
        durationMinutes: durationMinutes,
        currentPrice: price,
      );

  @override
  List<Object?> get props => [
        id,
        businessId,
        name,
        jotformAlias,
        isActive,
        categoryId,
        hasDuration,
        hasQuantity,
        durationMinutes,
        currentPrice,
      ];
}
