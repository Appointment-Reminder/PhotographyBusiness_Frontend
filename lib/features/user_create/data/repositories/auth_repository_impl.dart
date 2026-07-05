
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_local_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_remote_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final AuthLocalDatasource local;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl(this.remote, this.local, this.networkInfo);

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
  Future<Either<Failure, AuthResult>> login({required String email, required String password}) async {
    return _execute(() => remote.login(email, password));
  }

  @override
  Future<Either<Failure, AuthResult>> register({required String name, required String email, required String password}) async {
    return _execute(() => remote.register(name, email, password));
  }

  @override
  Future<Either<Failure, void>> logout() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AuthResult>> checkAuthStatus() async {
    try {
      final cachedAuth = await local.getCachedUserLogin();

      if (cachedAuth == null) {
        return const Left(CacheFailure('No saved session'));
      }

      final isOnline = await networkInfo.isConnected;

      if (isOnline) {
        // Validate token with backend when online
        try {
          final user = await remote.validateToken(cachedAuth.token);
          final validatedAuth = AuthResult(user: user, token: cachedAuth.token);
          return Right(validatedAuth);
        } on DioException catch (e) {

          if (e.response?.statusCode == 401) {
            return const Left(CacheFailure('Failed to restore session'));
          }
          // If other error, fall back to cached data
          return Right(cachedAuth);
        }
      }

      // Offline: return cached data
      return Right(cachedAuth);
    } catch (e, stackTrace) {
      return const Left(CacheFailure('Failed to restore session'));
    }
  }
}