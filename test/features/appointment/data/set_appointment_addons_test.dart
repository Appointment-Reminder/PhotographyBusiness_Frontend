import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import 'package:photography_business_frontend/features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:photography_business_frontend/features/appointment/data/repositories/appointment_repository_impl.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment_addon.dart';

class _Online implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;
}

AppointmentAddon addonLine(int addonId, int quantity) => AppointmentAddon(
      id: addonId,
      addonId: addonId,
      quantity: quantity,
      unitPrice: 10,
      priceTotal: 10.0 * quantity,
    );

Appointment appointment(List<AppointmentAddon> addons) => Appointment(
      id: 1,
      businessId: 7,
      formId: null,
      clientFirstName: 'C',
      clientLastName: 'L',
      appointmentDate: DateTime(2026),
      status: 'pending',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      addons: addons,
    );

/// A fake backend that applies each request to its own Add-on list.
class FakeDatasource implements AppointmentRemoteDatasource {
  List<AppointmentAddon> addons;
  final calls = <String>[];
  String? failOn; // e.g. 'PATCH 2'

  FakeDatasource(this.addons);

  Future<Appointment> _apply(String call, void Function() change) async {
    calls.add(call);
    if (call == failOn) {
      throw DioException(requestOptions: RequestOptions(path: '/x'));
    }
    change();
    return appointment(addons);
  }

  @override
  Future<Appointment> getAppointmentById({required int businessId, required int appointmentId}) async {
    calls.add('GET');
    return appointment(addons);
  }

  @override
  Future<Appointment> addAppointmentAddon({
    required int businessId,
    required int appointmentId,
    required int addonId,
    required int quantity,
  }) =>
      _apply('POST $addonId', () => addons = [...addons, addonLine(addonId, quantity)]);

  @override
  Future<Appointment> changeAppointmentAddonQuantity({
    required int businessId,
    required int appointmentId,
    required int addonId,
    required int quantity,
  }) =>
      _apply('PATCH $addonId', () {
        addons = [for (final a in addons) a.addonId == addonId ? addonLine(addonId, quantity) : a];
      });

  @override
  Future<Appointment> removeAppointmentAddon({
    required int businessId,
    required int appointmentId,
    required int addonId,
  }) =>
      _apply('DELETE $addonId', () => addons = addons.where((a) => a.addonId != addonId).toList());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  FakeDatasource backend(List<AppointmentAddon> addons) => FakeDatasource(addons);
  AppointmentRepositoryImpl repo(FakeDatasource d) =>
      AppointmentRepositoryImpl(remoteDatasource: d, networkInfo: _Online());

  test('sends only what changed, adds then changes then removes, and returns the '
      'final Appointment', () async {
    final d = backend([addonLine(1, 1), addonLine(2, 3), addonLine(3, 2)]);

    final result = await repo(d).setAppointmentAddons(
      businessId: 7,
      appointmentId: 1,
      desired: {2: 5, 3: 2, 4: 1},
    );

    expect(d.calls, ['GET', 'POST 4', 'PATCH 2', 'DELETE 1']);
    final a = result.getOrElse(() => throw 'expected success');
    expect(a.addons.map((x) => '${x.addonId}x${x.quantity}'), ['2x5', '3x2', '4x1']);
  });

  test('an unchanged draft sends nothing but the read', () async {
    final d = backend([addonLine(1, 1)]);

    final result = await repo(d).setAppointmentAddons(
      businessId: 7,
      appointmentId: 1,
      desired: {1: 1},
    );

    expect(d.calls, ['GET']);
    expect(result.isRight(), isTrue);
  });

  test('stops at the first failure and does not send the rest', () async {
    final d = backend([addonLine(1, 1), addonLine(2, 1)])..failOn = 'PATCH 2';

    final result = await repo(d).setAppointmentAddons(
      businessId: 7,
      appointmentId: 1,
      desired: {1: 0, 2: 4, 3: 1},
    );

    expect(result.isLeft(), isTrue);
    expect(d.calls, ['GET', 'POST 3', 'PATCH 2']);
  });
}
