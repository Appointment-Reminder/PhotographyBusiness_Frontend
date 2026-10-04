import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/addon/domain/entities/addon.dart';
import '../entities/appointment_addon.dart';

/// Who may change an Appointment's Add-ons, and when. The backend still
/// decides; this only hides what would be refused.
class AppointmentAddonEditing {
  AppointmentAddonEditing._();

  static const _closedStatuses = {'completed', 'canceled', 'refunded'};

  static bool canEdit({required bool isManager, required String status}) =>
      isManager && !_closedStatuses.contains(status);
}

/// The editor's draft: Add-on id to quantity, held until Save.
class AddonDraft extends Equatable {
  final Map<int, int> quantities;
  const AddonDraft(this.quantities);

  factory AddonDraft.from(List<AppointmentAddon> current) =>
      AddonDraft({for (final a in current) a.addonId: a.quantity});

  bool isSelected(int addonId) => (quantities[addonId] ?? 0) > 0;
  int quantityOf(int addonId) => quantities[addonId] ?? 0;

  AddonDraft toggle(int addonId) {
    final next = {...quantities};
    if (isSelected(addonId)) {
      next.remove(addonId);
    } else {
      next[addonId] = 1;
    }
    return AddonDraft(next);
  }

  /// Quantity is at least 1; deselecting is done with [toggle].
  AddonDraft withQuantity(int addonId, int quantity) =>
      AddonDraft({...quantities, addonId: quantity < 1 ? 1 : quantity});

  @override
  List<Object?> get props => [quantities];
}

/// An Add-on the editor shows, and whether the user may newly select it.
class AddonChoice extends Equatable {
  final Addon addon;

  /// False for an inactive Add-on already on the Appointment: it stays shown
  /// (history stays truthful) but cannot be newly selected. Also false for an
  /// Add-on with no current price, which the backend could not freeze.
  final bool canSelectNew;
  const AddonChoice(this.addon, {required this.canSelectNew});

  @override
  List<Object?> get props => [addon, canSelectNew];

  /// Active Add-ons, plus inactive ones already on the Appointment.
  static List<AddonChoice> build(List<Addon> catalog, List<AppointmentAddon> onAppointment) {
    final onIds = {for (final a in onAppointment) a.addonId};
    return [
      for (final a in catalog)
        if (a.isActive || onIds.contains(a.id))
          AddonChoice(a, canSelectNew: a.isActive && a.currentPrice != null),
    ];
  }
}
