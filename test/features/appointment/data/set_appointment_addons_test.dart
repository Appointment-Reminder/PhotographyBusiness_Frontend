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

/// A fake backend whose replace applies the whole set or nothing.
class FakeDatasource implements AppointmentRemoteDatasource {
  List<AppointmentAddon> addons;
  final calls = <String>[];
  bool fail = false;

  FakeDatasource(this.addons);

  @override
  Future<Appointment> replaceAppointmentAddons({
    required int businessId,
    required int appointmentId,
    required Map<int, int> addons,
  }) async {
    calls.add('PUT $addons');
    if (fail) throw DioException(requestOptions: RequestOptions(path: '/x'));
    this.addons = [for (final e in addons.entries) addonLine(e.key, e.value)];
    return appointment(this.addons);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  AppointmentRepositoryImpl repo(FakeDatasource d) =>
      AppointmentRepositoryImpl(remoteDatasource: d, networkInfo: _Online());

  test('sends the whole desired set in one request and returns the Appointment', () async {
    final d = FakeDatasource([addonLine(1, 1)]);

    final result = await repo(d).setAppointmentAddons(
      businessId: 7,
      appointmentId: 1,
      desired: {2: 5, 3: 2},
    );

    expect(d.calls, ['PUT {2: 5, 3: 2}']);
    final a = result.getOrElse(() => throw 'expected success');
    expect(a.addons.map((x) => '${x.addonId}x${x.quantity}'), ['2x5', '3x2']);
  });

  test('leaves out Add-ons whose quantity is zero', () async {
    final d = FakeDatasource([]);

    await repo(d).setAppointmentAddons(
      businessId: 7,
      appointmentId: 1,
      desired: {1: 0, 2: 1},
    );

    expect(d.calls, ['PUT {2: 1}']);
  });

  test('a failure comes back as a failure and nothing is applied', () async {
    final d = FakeDatasource([addonLine(1, 1)])..fail = true;

    final result = await repo(d).setAppointmentAddons(
      businessId: 7,
      appointmentId: 1,
      desired: {1: 0},
    );

    expect(result.isLeft(), isTrue);
    expect(d.addons.map((a) => a.addonId), [1]);
  });
}
