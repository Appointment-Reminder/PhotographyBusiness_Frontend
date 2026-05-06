
import 'package:photography_business_frontend/features/user_create/domain/entities/user.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  final String token;

  const AuthAuthenticated({required this.user, required this.token});
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState{
  final String message;

  const AuthError(this.message);
}
