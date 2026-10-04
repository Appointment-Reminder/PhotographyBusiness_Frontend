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

Addon addon(int id, {bool active = true, int? price = 10}) => Addon(
      id: id,
      businessId: 7,
      name: 'A$id',
      jotformAlias: 'a$id',
      isActive: active,
      hasDuration: false,
      hasQuantity: true,
      currentPrice: price,
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

    test('an active Add-on with no current price is shown but cannot be newly '
        'selected, since there is no price to freeze', () {
      final choices = AddonChoice.build([addon(1, price: null)], const []);

      expect(choices.single.addon.id, 1);
      expect(choices.single.canSelectNew, isFalse);
    });
  });
}
