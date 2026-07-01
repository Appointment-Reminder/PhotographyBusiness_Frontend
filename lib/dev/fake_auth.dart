import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/repositories/auth_repository.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/checkAuthStatus_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/login_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/logout_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/register_user.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/notifiers/auth_notifier.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';
import 'Fixtures.dart';

class _UnusedAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, AuthResult>> login({required String email, required String password}) =>
      throw UnimplementedError('not used in preview');
  @override
  Future<Either<Failure, AuthResult>> register({required String name, required String email, required String password}) =>
      throw UnimplementedError('not used in preview');
  @override
  Future<Either<Failure, AuthResult>> checkAuthStatus() =>
      throw UnimplementedError('not used in preview');
  @override
  Future<Either<Failure, void>> logout() =>
      throw UnimplementedError('not used in preview');
}

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier()
      : super(
    loginUser: LoginUser(_UnusedAuthRepository()),
    registerUser: RegisterUser(_UnusedAuthRepository()),
    checkAuthStatusUser: CheckAuthStatusUser(_UnusedAuthRepository()),
    logoutUser: LogoutUser(_UnusedAuthRepository()),
  ) {
    state = AuthAuthenticated(user: Fixtures.user, token: 'fake-token');
  }
}