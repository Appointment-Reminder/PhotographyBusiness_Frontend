import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/addons/appointment_addon_editing.dart';
import '../../domain/workflow/appointment_event.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  AppointmentRepositoryImpl({
    required this.remoteDatasource,
    required this.networkInfo,
  });

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure('No internet connection'));
      }
      return Right(await action());
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      print("error of appointment ${e}");
      return const Left(ServerFailure("Unexpected error Appointment "));
    }
  }

  @override
  Future<Either<Failure, Appointment>> createAppointment({
    int? memberId,
    int? businessId,
    required int packageId,
    required int packagePriceId,
    required String clientFirstName,
    required String clientLastName,
    required DateTime appointmentDate,
    required double priceAtBooking,
    required double depositAmount,
    required double remainingAmount,
    required double commissionPercentAtBooking,
    required double commissionAmountAtBooking,
  }) {
    return _execute(() => remoteDatasource.createAppointment(
          memberId: memberId,
          businessId: businessId,
          packageId: packageId,
          packagePriceId: packagePriceId,
          clientFirstName: clientFirstName,
          clientLastName: clientLastName,
          appointmentDate: appointmentDate,
          priceAtBooking: priceAtBooking,
          depositAmount: depositAmount,
          remainingAmount: remainingAmount,
          commissionPercentAtBooking: commissionPercentAtBooking,
          commissionAmountAtBooking: commissionAmountAtBooking,
        ));
  }

  @override
  Future<Either<Failure, List<Appointment>>> getMyAppointments({String? status}) {
    return _execute(() => remoteDatasource.getMyAppointments(status: status));
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsForBusiness({
    required int businessId,
    String? status,
  }) {
    return _execute(() => remoteDatasource.getAppointmentsForBusiness(
          businessId: businessId,
          status: status,
        ));
  }

  @override
  Future<Either<Failure, Appointment>> getAppointmentById({
    required int businessId,
    required int appointmentId,
  }) {
    return _execute(() => remoteDatasource.getAppointmentById(
          businessId: businessId,
          appointmentId: appointmentId,
        ));
  }

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
  }) {
    return _execute(() => remoteDatasource.updateAppointment(
          businessId: businessId,
          appointmentId: appointmentId,
          clientFirstName: clientFirstName,
          clientLastName: clientLastName,
          clientEmail: clientEmail,
          clientPhone: clientPhone,
          appointmentDate: appointmentDate,
          appointmentLocation: appointmentLocation,
          appointmentDuration: appointmentDuration,
          appointmentNote: appointmentNote,
          numberOfPersons: numberOfPersons,
          privacyOptOut: privacyOptOut,
          addsOns: addsOns,
          memberId: memberId,
        ));
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(int appointmentId) {
    return _execute(() => remoteDatasource.deleteAppointment(appointmentId));
  }

  @override
  Future<Either<Failure, Appointment>> fireAppointmentEvent({
    required int businessId,
    required int appointmentId,
    required AppointmentEvent event,
  }) {
    return _execute(() => remoteDatasource.fireAppointmentEvent(
          businessId: businessId,
          appointmentId: appointmentId,
          event: event,
        ));
  }

  /// Diffs against the server's current Add-ons and applies only what changed
  /// (adds, quantity changes, removes), stopping at the first failure. Not
  /// atomic: a failure can leave the Appointment half-updated, so callers
  /// refetch it.
  @override
  Future<Either<Failure, Appointment>> setAppointmentAddons({
    required int businessId,
    required int appointmentId,
    required Map<int, int> desired,
  }) async {
    var current = await getAppointmentById(
      businessId: businessId,
      appointmentId: appointmentId,
    );
    final changes = current.fold(
      (_) => const <AddonChange>[],
      (a) => diffAddons(a.addons, desired),
    );
    for (final change in changes) {
      final next = await _execute(() => switch (change) {
            AddAddon(:final addonId, :final quantity) => remoteDatasource.addAppointmentAddon(
                businessId: businessId,
                appointmentId: appointmentId,
                addonId: addonId,
                quantity: quantity,
              ),
            ChangeAddonQuantity(:final addonId, :final quantity) =>
              remoteDatasource.changeAppointmentAddonQuantity(
                businessId: businessId,
                appointmentId: appointmentId,
                addonId: addonId,
                quantity: quantity,
              ),
            RemoveAddon(:final addonId) => remoteDatasource.removeAppointmentAddon(
                businessId: businessId,
                appointmentId: appointmentId,
                addonId: addonId,
              ),
          });
      if (next.isLeft()) return next;
      current = next;
    }
    return current;
  }

  @override
  Future<Either<Failure, Appointment>> resolveUnresolvedAddon({
    required int businessId,
    required int appointmentId,
    required int unresolvedId,
    required int addonId,
    required int quantity,
  }) {
    return _execute(() => remoteDatasource.resolveUnresolvedAddon(
          businessId: businessId,
          appointmentId: appointmentId,
          unresolvedId: unresolvedId,
          addonId: addonId,
          quantity: quantity,
        ));
  }
}
