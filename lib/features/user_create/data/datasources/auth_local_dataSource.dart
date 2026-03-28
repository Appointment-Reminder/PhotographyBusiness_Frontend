import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';

abstract class AuthLocalDatasource {
  Future<AuthResult> Login();

  Future<void> cacheUserLogin(AuthResult authResult);

  Future<AuthResult?> getCachedUserLogin();

  Future<void> Logout();

}