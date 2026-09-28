import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import '../datasources/appointment_remote_datasource.dart';
import '../../domain/entities/appointment.dart';
import '../../domain/repositories/appointment_repository.dart';

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
}
