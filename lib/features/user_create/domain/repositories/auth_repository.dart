import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResult>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResult>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthResult>> checkAuthStatus();

  Future<Either<Failure, void>> logout();
}