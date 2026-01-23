import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/repositories/auth_repository.dart';

class RegisterUser extends Usecase<AuthResult, RegisterUserParams>{
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(RegisterUserParams params) {
    if(params.password.isEmpty || params.email.isEmpty || params.name.isEmpty){
      return Future.value(
        const Left(ServerFailure('Incorrect user data')),
      );
    }

    return repository.register(name: params.name, email: params.email, password: params.password);
  }
}


class RegisterUserParams extends Equatable{
  final String email;
  final String name;
  final String password;

  const RegisterUserParams(this.email, this.name, this.password);

  @override
  // TODO: implement props
  List<Object?> get props => [email, name, password];
}