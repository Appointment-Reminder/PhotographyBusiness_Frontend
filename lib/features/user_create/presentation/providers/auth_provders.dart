import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_local_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_local_dataSource_Impl.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_remote_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_remote_dataSource_Impl.dart';
import 'package:photography_business_frontend/features/user_create/data/repositories/auth_repository_impl.dart';
import 'package:photography_business_frontend/features/user_create/domain/repositories/auth_repository.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/checkAuthStatus_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/login_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/logout_user.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/register_user.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/notifiers/auth_notifier.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(ref.read(dioProvider));
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final authLocalDataSourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasourceImpl(ref.read(sharedPreferencesProvider));
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.read(authRemoteDataSourceProvider),
    ref.read(authLocalDataSourceProvider),
    ref.read(networkInfoProvider),
  );
});

final logoutUseCaseProvider = Provider<LogoutUser>((ref){
  return LogoutUser(ref.read(authRepositoryProvider));
});

final loginUseCaseProvider = Provider<LoginUser>((ref) {
  return LoginUser(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUser>((ref) {
  return RegisterUser(ref.read(authRepositoryProvider));
});

final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUser>((ref) {
  return CheckAuthStatusUser(ref.read(authRepositoryProvider));
});

// Auth Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUser: ref.read(loginUseCaseProvider),
    registerUser: ref.read(registerUseCaseProvider),
    checkAuthStatusUser: ref.read(checkAuthStatusUseCaseProvider),
    logoutUser: ref.read(logoutUseCaseProvider),
  );
});
