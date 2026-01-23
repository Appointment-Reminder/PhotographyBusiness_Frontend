
import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_result.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final AuthResult? authResult;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.authResult,
    this.error
  });

  factory AuthState.initial() {
    return const AuthState(
      isLoading: false,
      authResult: null,
      error: null,
    );
  }

  AuthState copyWith({
    bool? isLoading,
    AuthResult? authResult,
    String? error,
  }){
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      authResult: authResult,
      error: error,
    );
  }

  @override
  // TODO: implement props
  List<Object?> get props => [isLoading, authResult, error];


}