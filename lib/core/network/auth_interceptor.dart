import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Get the current auth state
    final authState = ref.read(authNotifierProvider);

    // If user is authenticated, add the token
    if (authState is AuthAuthenticated) {
      options.headers['Authorization'] = 'Bearer ${authState.token}';
      print('🔵 Added token to request: ${options.path}');
    }

    print('On Request');
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('🔴 Request error: ${err.response?.statusCode}');
    print('🔴 Path: ${err.requestOptions.path}');

    // If 401, token might be expired - could trigger logout here
    if (err.response?.statusCode == 401) {
      print('🔴 Unauthorized - Token might be expired');
      // Optional: Auto-logout on 401
      // ref.read(authNotifierProvider.notifier).logout();
    }

    super.onError(err, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    print('🟢 Response from: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }
}