import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';

import '../repositories/auth_repository.dart';

class LoginUser implements Usecase<AuthResult, LoginParams> {
  final AuthRepository repository;
  
  LoginUser(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(LoginParams params) {
    // TODO: implement call

    if(params.email.isEmpty || params.password.isEmpty){
      return Future.value(
        const Left(ServerFailure('Email and password are required')),
      );
    }

    return repository.login(email: params.email, password: params.password);
  }
  
  
}

class LoginParams extends Equatable{
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];

}