import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/features/addon/domain/entities/addon.dart';
import 'package:photography_business_frontend/features/appointment/domain/addons/appointment_addon_editing.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment_addon.dart';

AppointmentAddon onAppointment(int addonId, int quantity) => AppointmentAddon(
      id: addonId * 10,
      addonId: addonId,
      quantity: quantity,
      unitPrice: 10,
      priceTotal: 10.0 * quantity,
    );

Addon addon(int id, {bool active = true}) => Addon(
      id: id,
      businessId: 7,
      name: 'A$id',
      jotformAlias: 'a$id',
      isActive: active,
      hasDuration: false,
      hasQuantity: true,
    );

void main() {
  group('canEdit', () {
    test('only owner and admin, and only while the Appointment is open', () {
      expect(AppointmentAddonEditing.canEdit(isManager: true, status: 'pending'), isTrue);
      expect(AppointmentAddonEditing.canEdit(isManager: true, status: 'needs_assignment'), isTrue);
      expect(AppointmentAddonEditing.canEdit(isManager: false, status: 'pending'), isFalse);
    });

    test('locked once completed, canceled or refunded', () {
      for (final status in ['completed', 'canceled', 'refunded']) {
        expect(AppointmentAddonEditing.canEdit(isManager: true, status: status), isFalse, reason: status);
      }
    });
  });

  group('diffAddons', () {
    final current = [onAppointment(1, 1), onAppointment(2, 3), onAppointment(3, 2)];

    test('nothing changed produces nothing, so untouched Add-ons keep their frozen price', () {
      expect(diffAddons(current, {1: 1, 2: 3, 3: 2}), isEmpty);
    });

    test('orders adds, then quantity changes, then removes', () {
      final changes = diffAddons(current, {2: 5, 3: 0, 4: 1});

      expect(changes, const [
        AddAddon(4, 1),
        ChangeAddonQuantity(2, 5),
        RemoveAddon(1),
        RemoveAddon(3),
      ]);
    });

    test('an Add-on absent from the draft is removed, zero means not selected', () {
      expect(diffAddons(current, {1: 1, 2: 3}), const [RemoveAddon(3)]);
      expect(diffAddons(current, {1: 1, 2: 3, 3: 0}), const [RemoveAddon(3)]);
    });
  });

  group('AddonDraft', () {
    test('starts from the Appointment Add-ons', () {
      final d = AddonDraft.from([onAppointment(1, 2)]);
      expect(d.isSelected(1), isTrue);
      expect(d.quantityOf(1), 2);
      expect(d.isSelected(2), isFalse);
    });

    test('toggle selects with quantity 1, then deselects', () {
      var d = const AddonDraft({}).toggle(5);
      expect(d.quantityOf(5), 1);
      d = d.toggle(5);
      expect(d.isSelected(5), isFalse);
    });

    test('quantity is at least 1', () {
      expect(const AddonDraft({1: 3}).withQuantity(1, 0).quantityOf(1), 1);
      expect(const AddonDraft({1: 3}).withQuantity(1, 4).quantityOf(1), 4);
    });
  });

  group('AddonChoice.build', () {
    test('offers active Add-ons, and inactive ones only if already on the '
        'Appointment, where they cannot be newly selected', () {
      final choices = AddonChoice.build(
        [addon(1), addon(2, active: false), addon(3, active: false)],
        [onAppointment(3, 1)],
      );

      expect(choices.map((c) => c.addon.id), [1, 3]);
      expect(choices.firstWhere((c) => c.addon.id == 1).canSelectNew, isTrue);
      expect(choices.firstWhere((c) => c.addon.id == 3).canSelectNew, isFalse);
    });
  });
}
