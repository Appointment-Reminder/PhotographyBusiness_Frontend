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

/// One request needed to turn the current Add-ons into the desired ones.
sealed class AddonChange extends Equatable {
  final int addonId;
  const AddonChange(this.addonId);
}

class AddAddon extends AddonChange {
  final int quantity;
  const AddAddon(super.addonId, this.quantity);
  @override
  List<Object?> get props => [addonId, quantity];
}

class ChangeAddonQuantity extends AddonChange {
  final int quantity;
  const ChangeAddonQuantity(super.addonId, this.quantity);
  @override
  List<Object?> get props => [addonId, quantity];
}

class RemoveAddon extends AddonChange {
  const RemoveAddon(super.addonId);
  @override
  List<Object?> get props => [addonId];
}

/// The requests that turn [current] into [desired] (Add-on id to quantity,
/// zero or absent meaning not selected): adds, then quantity changes, then
/// removes. Untouched Add-ons produce nothing, so they keep their frozen price.
List<AddonChange> diffAddons(List<AppointmentAddon> current, Map<int, int> desired) {
  final have = {for (final a in current) a.addonId: a.quantity};
  final want = {
    for (final e in desired.entries)
      if (e.value > 0) e.key: e.value,
  };
  return [
    for (final e in want.entries)
      if (!have.containsKey(e.key)) AddAddon(e.key, e.value),
    for (final e in want.entries)
      if (have.containsKey(e.key) && have[e.key] != e.value) ChangeAddonQuantity(e.key, e.value),
    for (final id in have.keys)
      if (!want.containsKey(id)) RemoveAddon(id),
  ];
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
  /// (history stays truthful) but cannot be newly selected.
  final bool canSelectNew;
  const AddonChoice(this.addon, {required this.canSelectNew});

  @override
  List<Object?> get props => [addon, canSelectNew];

  /// Active Add-ons, plus inactive ones already on the Appointment.
  static List<AddonChoice> build(List<Addon> catalog, List<AppointmentAddon> onAppointment) {
    final onIds = {for (final a in onAppointment) a.addonId};
    return [
      for (final a in catalog)
        if (a.isActive || onIds.contains(a.id)) AddonChoice(a, canSelectNew: a.isActive),
    ];
  }
}
