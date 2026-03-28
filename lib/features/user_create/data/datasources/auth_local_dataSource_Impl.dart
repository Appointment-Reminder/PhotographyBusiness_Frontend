

import 'dart:convert';

import 'package:photography_business_frontend/features/user_create/data/datasources/auth_local_dataSource.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/auth_result.dart';
import '../models/user_model.dart';

const String CACHED_AUTH_RESULT = 'CACHED_AUTH_RESULT';

class AuthLocalDatasourceImpl implements AuthLocalDatasource{
  final SharedPreferences sharedPreferences;

  AuthLocalDatasourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUserLogin(AuthResult authResult) async {
    final authResultJson = {
      'user': {
        'id': authResult.user.id,
        'email': authResult.user.email,
        'name': authResult.user.name,
      },
      'token': authResult.token,
    };

    await sharedPreferences.setString(
      CACHED_AUTH_RESULT,
      json.encode(authResultJson),
    );
  }

  @override
  Future<AuthResult?> getCachedUserLogin() async {
    final jsonString = sharedPreferences.getString(CACHED_AUTH_RESULT);

    if (jsonString == null) {
      return null;
    }

    final jsonMap = json.decode(jsonString);
    final user = UserModel.fromJson(jsonMap['user']);
    final token = jsonMap['token'] as String;

    return AuthResult(user: user, token: token);
  }

  @override
  Future<void> Logout() async {
    await sharedPreferences.remove(CACHED_AUTH_RESULT);
  }

  @override
  Future<AuthResult> Login() {
    // This seems like it shouldn't be in local datasource
    // Local datasource should only handle caching, not authentication
    throw UnimplementedError('Login should be handled by remote datasource');
  }
}