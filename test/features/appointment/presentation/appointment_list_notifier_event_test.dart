import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/delete_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/fire_appointment_event.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_appointments_for_business.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/get_my_appointments.dart';
import 'package:photography_business_frontend/features/appointment/domain/usecases/update_appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/appointment_event.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/workflow_column.dart';
import 'package:photography_business_frontend/features/appointment/presentation/providers/notifiers/appointment_list_notifier.dart';

class FakeRepository implements AppointmentRepository {
  Completer<Either<Failure, Appointment>>? pending;
  Either<Failure, Appointment>? response;
  final calls = <String>[];

  @override
  Future<Either<Failure, Appointment>> fireAppointmentEvent({
    required int businessId,
    required int appointmentId,
    required AppointmentEvent event,
  }) {
    calls.add('$businessId/$appointmentId/${event.wireName}');
    return pending?.future ?? Future.value(response);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Appointment appointment(int id, String status) => Appointment(
      id: id,
      businessId: 7,
      formId: null,
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
    );
    notifier.state = notifier.state.copyWith(appointments: [
      appointment(1, 'pending'),
      appointment(2, 'pending_review'),
    ]);
  });

  String statusOf(int id) =>
      notifier.state.appointments.firstWhere((a) => a.id == id).status;

  test('moves the card optimistically, before the backend answers', () async {
    repo.pending = Completer();
    final future = notifier.fireEvent(
        businessId: 7, appointmentId: 1, event: AppointmentEvent.photoshoot);

    expect(statusOf(1), 'pending_selection');
    expect(repo.calls, ['7/1/photoshoot']);

    repo.pending!.complete(Right(appointment(1, 'pending_selection')));
    expect(await future, isNull);
    expect(statusOf(1), 'pending_selection');
  });

  test('keeps the server appointment on success', () async {
    repo.response = Right(appointment(2, 'completed'));
    expect(
        await notifier.fireEvent(
            businessId: 7, appointmentId: 2, event: AppointmentEvent.review),
        isNull);
    expect(statusOf(2), 'completed');
  });

  test('rolls back and returns the error message on failure', () async {
    repo.response = const Left(ServerFailure('Forbidden'));
    final error = await notifier.fireEvent(
        businessId: 7, appointmentId: 1, event: AppointmentEvent.photoshoot);

    expect(error, 'Forbidden');
    expect(statusOf(1), 'pending');
    expect(notifier.state.error, isNull);
  });

  test('rollback does not disturb other cards', () async {
    repo.pending = Completer();
    final first = notifier.fireEvent(
        businessId: 7, appointmentId: 1, event: AppointmentEvent.photoshoot);
    final second = notifier.fireEvent(
        businessId: 7, appointmentId: 2, event: AppointmentEvent.review);
    expect(statusOf(1), 'pending_selection');
    expect(statusOf(2), 'completed');

    repo.pending!.complete(const Left(ServerFailure('boom')));
    await Future.wait([first, second]);
    expect(statusOf(1), 'pending');
    expect(statusOf(2), 'pending_review');
  });

  test('canceled and refund events take the card off the board', () async {
    repo.pending = Completer();
    final cancel = notifier.fireEvent(
        businessId: 7, appointmentId: 1, event: AppointmentEvent.canceled);
    final refund = notifier.fireEvent(
        businessId: 7, appointmentId: 2, event: AppointmentEvent.refund);
    expect(statusOf(1), 'canceled');
    expect(statusOf(2), 'refunded');
    expect(workflowColumnForStatus(statusOf(1)), isNull);
    expect(workflowColumnForStatus(statusOf(2)), isNull);

    repo.pending!.complete(const Left(ServerFailure('nope')));
    expect(await cancel, 'nope');
    await refund;
    expect(statusOf(1), 'pending');
    expect(statusOf(2), 'pending_review');
  });
}
