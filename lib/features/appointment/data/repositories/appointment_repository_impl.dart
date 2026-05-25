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

  @override
  Future<Either<Failure, Appointment>> createAppointment({
    required String clientName,
    required String clientEmail,
    String? clientPhone,
    required DateTime appointmentDate,
    int? userId,
    int? businessId,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      // userId and businessId are now required
      if (userId == null || businessId == null) {
        return const Left(ServerFailure('User ID and Business ID are required'));
      }

      final appointment = await remoteDatasource.createAppointment(
        clientName: clientName,
        clientEmail: clientEmail,
        clientPhone: clientPhone,
        appointmentDate: appointmentDate,
        userId: userId,
        businessId: businessId,
      );

      return Right(appointment);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getMyAppointments({String? status}) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final appointments = await remoteDatasource.getMyAppointments(status: status);
      return Right(appointments);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error '));
    }
  }

  @override
  Future<Either<Failure, List<Appointment>>> getAppointmentsForBusiness({
    required int businessId,
    String? status,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      print('get appointments for business ');
      final appointments = await remoteDatasource.getAppointmentsForBusiness(
        businessId: businessId,
        status: status,
      );
      return Right(appointments);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      print('error in getting appointment ${e}');
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, Appointment>> getAppointmentById({
    required int businessId,
    required int appointmentId,
  }) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final appointment = await remoteDatasource.getAppointmentById(
        businessId: businessId,
        appointmentId: appointmentId,
      );
      return Right(appointment);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
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
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      final appointment = await remoteDatasource.updateAppointment(
        businessId: businessId,
        appointmentId: appointmentId,
        clientName: clientName,
        clientEmail: clientEmail,
        clientPhone: clientPhone,
        appointmentDate: appointmentDate,
        userId: userId,
      );
      return Right(appointment);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAppointment(int appointmentId) async {
    try {
      final isOnline = await networkInfo.isConnected;
      if (!isOnline) {
        return const Left(ServerFailure('No internet connection'));
      }

      await remoteDatasource.deleteAppointment(appointmentId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (e) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }
}