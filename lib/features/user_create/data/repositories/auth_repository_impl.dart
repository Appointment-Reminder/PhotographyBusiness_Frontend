
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
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

  @override
  Future<Either<Failure, AuthResult>> login({required String email, required String password}) async {

    try{
      print('🔵 Checking network...');
      final isOnline = await networkInfo.isConnected;
      print('🔵 Network status: $isOnline');
      if(!isOnline) {
        print('🔴 No network connection');
        return Left(ServerFailure('No internet connection'));
      }
      print('🔵 Calling remote datasource...');
      final result = await remote.login(email, password);
      print('🟢 Remote datasource success');

      print('🔵 Caching login...');
      await local.cacheUserLogin(result);
      print('🟢 Cache success');

      return Right(result);
    }
    on DioException catch (e){
      print('🔴 DioException: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      print('🔴 Status code: ${e.response?.statusCode}');
      if(e.response?.statusCode == 400){
        return const Left(ServerFailure('Wrong Credential'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
    catch(e, stackTrace){
      print('🔴 Unexpected error in repository: $e');
      print('Stack trace: $stackTrace');
      return const Left(ServerFailure('Unexpected error'));
    }

  }

  @override
  Future<Either<Failure, AuthResult>> register({required String name, required String email, required String password}) async {
    try{
      final isOnline = await networkInfo.isConnected;
      if(!isOnline){
        return const Left(ServerFailure('No internet connection'));
      }

      final result = await remote.register(name, email, password);

      await local.cacheUserLogin(result);

      return Right(result);
    } on DioException catch(e){
      if(e.response?.statusCode == 409){
        return const Left(ServerFailure('Email already exists'));
      }
      if(e.response?.statusCode == 422){
        return const Left(ServerFailure('Invalid input data'));
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AuthResult>> checkAuthStatus() async {
    try {
      print('🔵 Checking auth status...');
      final cachedAuth = await local.getCachedUserLogin();

      if (cachedAuth == null) {
        print('🔴 No cached auth found');
        return const Left(CacheFailure('No saved session'));
      }

      print('🟢 Found cached auth: ${cachedAuth.user.email}');
      print('🔵 Token: ${cachedAuth.token}');

      final isOnline = await networkInfo.isConnected;
      print('🔵 Network status: $isOnline');

      if (isOnline) {
        // Validate token with backend when online
        try {
          print('🔵 Validating token with backend...');
          final user = await remote.validateToken(cachedAuth.token);
          print('🟢 Token validated successfully');
          final validatedAuth = AuthResult(user: user, token: cachedAuth.token);
          return Right(validatedAuth);
        } on DioException catch (e) {
          print('🔴 Token validation failed');
          print('🔴 Status code: ${e.response?.statusCode}');
          print('🔴 Response: ${e.response?.data}');
          print('🔴 Error: ${e.message}');

          if (e.response?.statusCode == 401) {
            return const Left(CacheFailure('Failed to restore session'));
          }
          // If other error, fall back to cached data
          print('⚠️ Falling back to cached data');
          return Right(cachedAuth);
        }
      }

      // Offline: return cached data
      print('🟢 Returning cached data (offline)');
      return Right(cachedAuth);
    } catch (e, stackTrace) {
      print('🔴 Unexpected error in checkAuthStatus: $e');
      print('Stack trace: $stackTrace');
      return const Left(CacheFailure('Failed to restore session'));
    }
  }
}