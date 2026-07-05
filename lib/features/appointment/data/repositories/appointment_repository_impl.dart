import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import 'package:photography_business_frontend/features/appointment/data/datasources/appointment_remote_datasource.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/repositories/appointment_repository.dart';

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
      final result = await action();
      return Right(result);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Appointment>> createAppointment({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    required DateTime appointmentDate,
    int? userId,
    int? businessId,
  }) async {
    // userId and businessId are now required
    if (userId == null || businessId == null) {
      return const Left(ServerFailure('User ID and Business ID are required'));
    }

    return _execute(() => remoteDatasource.createAppointment(
      clientName: clientName,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      appointmentDate: appointmentDate,
      userId: userId,
      businessId: businessId,
    ));
  }

  @override
  Future<Either<Failure, List<Appointment>>> getMyAppointments({String? status}) async {
    return _execute(() => remoteDatasource.getMyAppointments(status: status));
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsForBusiness({
    required int businessId,
    String? status,
  }) async {
    return _execute(() => remoteDatasource.getAppointmentsForBusiness(
      businessId: businessId,
      status: status,
    ));
  }

  @override
  Future<Either<Failure, Appointment>> getAppointmentById({
    required int businessId,
    required int appointmentId,
  }) async {

    return _execute(() => remoteDatasource.getAppointmentById(
      businessId: businessId,
      appointmentId: appointmentId,
    ));
  }

  @override
  Future<Either<Failure, Appointment>> updateAppointment({
    required int businessId,
    required int appointmentId,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? appointmentDate,
    int? userId,
  }) async {

    return _execute(() => remoteDatasource.updateAppointment(
      businessId: businessId,
      appointmentId: appointmentId,
      clientName: clientName,
      clientEmail: clientEmail,
      clientPhone: clientPhone,
      appointmentDate: appointmentDate,
      userId: userId,
    ));
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(int appointmentId) async {
    return _execute(() => remoteDatasource.deleteAppointment(appointmentId));
  }
}