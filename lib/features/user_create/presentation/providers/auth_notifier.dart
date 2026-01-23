import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/login_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/register_user.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_state.dart';

import 'auth_provider.dart';

class AuthNotifier extends StateNotifier<AuthState>{
  final LoginUser loginUser;

  AuthNotifier({required this.loginUser}) : super (AuthState.initial());

  Future<void> login({
    required String email,
    required String password,
}) async{
    state = state.copyWith(isLoading: true, error: null);

    final result = await loginUser(LoginParams( email: email, password: password),
    );

    result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (authResult) {
          state = state.copyWith(
            isLoading: false,
            authResult: authResult,
            error: null,
          );
        },
    );
  }

  void logout(){
    state = AuthState.initial();
  }

}