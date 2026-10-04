import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/delete_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/fire_appointment_event.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_appointments_for_business.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_my_appointments.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_appointment_by_id.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/resolve_unresolved_addon.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/set_appointment_addons.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/update_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/appointment_event.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/notifiers/appointment_list_notifier.dart';

class FakeRepository implements AppointmentRepository {
  Either<Failure, Appointment>? patchResponse;
  Either<Failure, Appointment>? eventResponse;
  final calls = <String>[];

  @override
  Future<Either<Failure, Appointment>> updateAppointment({
    required int businessId,
    required int appointmentId,
    String? clientFirstName,
    String? clientLastName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    String? appointmentLocation,
    String? appointmentDuration,
    String? appointmentNote,
    int? numberOfPersons,
    String? privacyOptOut,
    String? addsOns,
    int? memberId,
  }) async {
    calls.add('PATCH $businessId/$appointmentId member_id=$memberId');
    return patchResponse!;
  }

  @override
  Future<Either<Failure, Appointment>> fireAppointmentEvent({
    required int businessId,
    required int appointmentId,
    required AppointmentEvent event,
  }) async {
    calls.add('POST $businessId/$appointmentId/${event.wireName}');
    return eventResponse!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Appointment appointment(int id, String status, {int? memberId}) => Appointment(
      id: id,
      businessId: 7,
      formId: null,
      memberId: memberId,
      clientFirstName: 'C$id',
      clientLastName: 'L',
      appointmentDate: DateTime(2026, 1, id),
      status: status,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
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
      getAppointmentById: GetAppointmentById(repository: repo),
      setAppointmentAddons: SetAppointmentAddons(repository: repo),
      resolveUnresolvedAddon: ResolveUnresolvedAddon(repository: repo),
    );
    notifier.state = notifier.state.copyWith(appointments: [
      appointment(1, 'needs_assignment'),
      appointment(2, 'pending_selection', memberId: 3),
    ]);
  });

  Appointment byId(int id) =>
      notifier.state.appointments.firstWhere((a) => a.id == id);

  group('assign', () {
    test('only PATCHes member_id (no event) and takes the status from the '
        'response, so the card is Scheduled', () async {
      repo.patchResponse = Right(appointment(1, 'pending', memberId: 5));

      final error =
          await notifier.assign(businessId: 7, appointmentId: 1, memberId: 5);

      expect(error, isNull);
      expect(repo.calls, ['PATCH 7/1 member_id=5']);
      expect(byId(1).status, 'pending');
      expect(byId(1).memberId, 5);
    });

    test('does not move the card before the response arrives', () async {
      repo.patchResponse = Right(appointment(1, 'pending', memberId: 5));

      final pending =
          notifier.assign(businessId: 7, appointmentId: 1, memberId: 5);

      expect(byId(1).status, 'needs_assignment');
      await pending;
    });

    test('the card stays in Needs Assignment when the response still says so',
        () async {
      repo.patchResponse =
          Right(appointment(1, 'needs_assignment', memberId: 5));

      final error =
          await notifier.assign(businessId: 7, appointmentId: 1, memberId: 5);

      expect(error, isNull);
      expect(repo.calls, ['PATCH 7/1 member_id=5'], reason: 'no fallback event');
      expect(byId(1).status, 'needs_assignment');
      expect(byId(1).memberId, 5);
    });

    test('returns the error and leaves the card untouched on failure',
        () async {
      repo.patchResponse = const Left(ServerFailure('Forbidden'));

      final error =
          await notifier.assign(businessId: 7, appointmentId: 1, memberId: 5);

      expect(error, 'Forbidden');
      expect(repo.calls, ['PATCH 7/1 member_id=5']);
      expect(byId(1).status, 'needs_assignment');
      expect(byId(1).memberId, isNull);
    });

    test('reassigning an already-assigned card keeps its status', () async {
      repo.patchResponse =
          Right(appointment(2, 'pending_selection', memberId: 9));

      final error =
          await notifier.assign(businessId: 7, appointmentId: 2, memberId: 9);

      expect(error, isNull);
      expect(repo.calls, ['PATCH 7/2 member_id=9']);
      expect(byId(2).memberId, 9);
      expect(byId(2).status, 'pending_selection');
    });
  });
}
