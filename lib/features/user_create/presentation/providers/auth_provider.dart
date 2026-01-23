

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/user_create/data/repositories/auth_repository_impl.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_notifier.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_state.dart';

import '../../data/datasources/auth_remote_dataSource_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.read(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remote);
});

final loginUserProvider = Provider<LoginUser>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return LoginUser(repository); //replaced by di later
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref){
  final loginUser = ref.read(loginUserProvider);

  return AuthNotifier(loginUser: loginUser);
});