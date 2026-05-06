import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/checkAuthStatus_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/login_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/logout_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/register_user.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';

import '../../../../../core/usecases/usecase.dart';

class AuthNotifier extends StateNotifier<AuthState>{
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LogoutUser logoutUser;
  final CheckAuthStatusUser checkAuthStatusUser;

  AuthNotifier({
    required this.loginUser,
    required this.registerUser,
    required this.checkAuthStatusUser,
    required this.logoutUser,

  }) : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    print(' Login Started : $email');
    state = const AuthLoading();

    print('Calling login Use Case');
    final result = await loginUser( LoginParams(email: email, password: password));

    result.fold(
        (failure) {
          print(' Login Failed : ${failure.message} ');
          state =  AuthError(failure.message);
        } ,
        (authResult) => state = AuthAuthenticated(user: authResult.user, token: authResult.token));
  }

  Future<void> register(String name, String email, String password) async {
    state = const AuthLoading();

    final result = await registerUser(
      RegisterUserParams(email, name,password),
    );

    result.fold(
        (failure) => state = AuthError(failure.message),
        (authResult) => state = AuthAuthenticated(user: authResult.user, token: authResult.token),
    );
  }

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    final result = await checkAuthStatusUser(NoParams());

    result.fold(
          (failure) => state = const AuthUnauthenticated(),
          (authResult) => state = AuthAuthenticated(
        user: authResult.user,
        token: authResult.token,
      ),
    );
  }

  void logout(){
    state = const AuthUnauthenticated();
  }
}