import 'package:equatable/equatable.dart';

/// Mirrors AppointmentAddonRead: an Add-on on an Appointment, with the price,
/// duration and commission frozen when it was added.
class AppointmentAddon extends Equatable {
  final int id;
  final int addonId;
  final int addonPriceId;
  final int quantity;
  final double unitPrice;
  final int unitDuration;
  final double priceTotal;
  final double? commissionTotal;
  final String? rawLabel;

  const AppointmentAddon({
    required this.id,
    required this.addonId,
    this.addonPriceId = 0,
    required this.quantity,
    required this.unitPrice,
    this.unitDuration = 0,
    required this.priceTotal,
    this.commissionTotal,
    this.rawLabel,
  });

  /// The catalogue name, else the Jotform label, else "Add-on #id".
  String label(Map<int, String> namesById) =>
      namesById[addonId] ?? rawLabel ?? 'Add-on #$addonId';

  @override
  List<Object?> get props => [
        id,
        addonId,
        addonPriceId,
        quantity,
        unitPrice,
        unitDuration,
        priceTotal,
        commissionTotal,
        rawLabel,
      ];
}

/// Mirrors UnresolvedAddonRead: a Jotform label that matched no Add-on.
class UnresolvedAddon extends Equatable {
  final int id;
  final String rawLabel;

  const UnresolvedAddon({required this.id, required this.rawLabel});

  @override
  List<Object?> get props => [id, rawLabel];
}
