import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment_addon.dart';
import 'package:photography_business_frontend/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/delete_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/fire_appointment_event.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_appointments_for_business.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_my_appointments.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/resolve_unresolved_addon.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/set_appointment_addons.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/update_appointment.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/notifiers/appointment_list_notifier.dart';

class FakeRepository implements AppointmentRepository {
  Either<Failure, Appointment>? setResponse;
  Either<Failure, Appointment>? resolveResponse;
  Either<Failure, Appointment>? getResponse;
  final calls = <String>[];

  @override
  Future<Either<Failure, Appointment>> setAppointmentAddons({
    required int businessId,
    required int appointmentId,
    required Map<int, int> desired,
  }) async {
    calls.add('SET $businessId/$appointmentId $desired');
    return setResponse!;
  }

  @override
  Future<Either<Failure, Appointment>> resolveUnresolvedAddon({
    required int businessId,
    required int appointmentId,
    required int unresolvedId,
    required int addonId,
    required int quantity,
  }) async {
    calls.add('RESOLVE $appointmentId/$unresolvedId -> $addonId x$quantity');
    return resolveResponse!;
  }

  @override
  Future<Either<Failure, Appointment>> getAppointmentById({
    required int businessId,
    required int appointmentId,
  }) async {
    calls.add('GET $businessId/$appointmentId');
    return getResponse!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AppointmentAddon line(int addonId, int quantity) => AppointmentAddon(
      id: addonId,
      addonId: addonId,
      quantity: quantity,
      unitPrice: 10,
      priceTotal: 10.0 * quantity,
    );

Appointment appointment(
  int id,
  String status, {
  List<AppointmentAddon> addons = const [],
  List<UnresolvedAddon> unresolved = const [],
}) =>
    Appointment(
      id: id,
      businessId: 7,
      formId: null,
      clientFirstName: 'C$id',
      clientLastName: 'L',
      appointmentDate: DateTime(2026, 1, id),
      status: status,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
      addons: addons,
      unresolvedAddons: unresolved,
    );

void main() {
  late FakeRepository repo;
  late AppointmentListNotifier notifier;

  setUp(() {
    repo = FakeRepository();
    notifier = AppointmentListNotifier(
      getMyAppointments: GetMyAppointments(repository: repo),
      getAppointmentsForBusiness: GetAppointmentsForBusiness(repository: repo),
      deleteAppointment: DeleteAppointment(repository: repo),
      fireAppointmentEvent: FireAppointmentEvent(repository: repo),
      updateAppointment: UpdateAppointment(repository: repo),
      setAppointmentAddons: SetAppointmentAddons(repository: repo),
      resolveUnresolvedAddon: ResolveUnresolvedAddon(repository: repo),
    );
    notifier.state = notifier.state.copyWith(appointments: [
      appointment(1, 'pending', addons: [line(1, 1)]),
      appointment(2, 'completed'),
      appointment(3, 'pending', unresolved: [const UnresolvedAddon(id: 9, rawLabel: 'Drone shots')]),
    ]);
  });

  Appointment byId(int id) => notifier.state.appointments.firstWhere((a) => a.id == id);

  group('setAddons', () {
    test('sends the draft once and replaces the Appointment with the response', () async {
      repo.setResponse = Right(appointment(1, 'pending', addons: [line(1, 1), line(2, 2)]));

      final error = await notifier.setAddons(
        businessId: 7,
        appointmentId: 1,
        desired: {1: 1, 2: 2},
      );

      expect(error, isNull);
      expect(repo.calls, ['SET 7/1 {1: 1, 2: 2}']);
      expect(byId(1).addons.map((a) => a.addonId), [1, 2]);
      expect(byId(1).addonTotal, 30);
    });

    test('on failure shows the error and leaves the Appointment as it was, with no refetch', () async {
      repo.setResponse = const Left(ServerFailure('quantity refused'));
      final before = byId(1);

      final error = await notifier.setAddons(
        businessId: 7,
        appointmentId: 1,
        desired: {1: 1, 2: 5},
      );

      expect(error, 'quantity refused');
      expect(repo.calls, ['SET 7/1 {1: 1, 2: 5}']);
      expect(byId(1), before);
    });

    test('is refused on a completed Appointment without calling the backend', () async {
      final error = await notifier.setAddons(
        businessId: 7,
        appointmentId: 2,
        desired: {1: 1},
      );

      expect(error, isNotNull);
      expect(repo.calls, isEmpty);
    });

    test('is refused for an unknown Appointment', () async {
      final error = await notifier.setAddons(businessId: 7, appointmentId: 99, desired: {});

      expect(error, 'Appointment not found');
      expect(repo.calls, isEmpty);
    });
  });

  group('resolveAddon', () {
    test('the chip becomes an Appointment Add-on from the response', () async {
      repo.resolveResponse = Right(appointment(3, 'pending', addons: [line(4, 2)]));

      final error = await notifier.resolveAddon(
        businessId: 7,
        appointmentId: 3,
        unresolvedId: 9,
        addonId: 4,
        quantity: 2,
      );

      expect(error, isNull);
      expect(repo.calls, ['RESOLVE 3/9 -> 4 x2']);
      expect(byId(3).unresolvedAddons, isEmpty);
      expect(byId(3).addons.single.addonId, 4);
    });

    test('on failure returns the error and the chip stays', () async {
      repo.resolveResponse = const Left(ServerFailure('no such add-on'));

      final error = await notifier.resolveAddon(
        businessId: 7,
        appointmentId: 3,
        unresolvedId: 9,
        addonId: 4,
        quantity: 1,
      );

      expect(error, 'no such add-on');
      expect(byId(3).unresolvedAddons.single.id, 9);
      expect(byId(3).addons, isEmpty);
    });
  });
}
