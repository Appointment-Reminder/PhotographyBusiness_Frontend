
import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_remote_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, AuthResult>> login({required String email, required String password}) async {
    try{
      final result = await remote.login(email, password);
      return Right(result);
    }
    on DioException catch (e){
      if(e.response?.statusCode == 401){
        return const Left(InvalidCredentialsFailure());
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    }
    catch(_){
      return const Left(ServerFailure('Unexpected error'));
    }

  }

  @override
  Future<Either<Failure, AuthResult>> register({required String name, required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logout() {
    throw UnimplementedError();
  }

}