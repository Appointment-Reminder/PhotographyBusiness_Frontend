
import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/usecases/usecase.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/repositories/auth_repository.dart';

class CheckAuthStatusUser  implements Usecase<AuthResult, NoParams>{
  final AuthRepository repository;

  CheckAuthStatusUser(this.repository);

  @override
  Future<Either<Failure, AuthResult>> call(NoParams params) async {
    return await repository.checkAuthStatus();
  }
}