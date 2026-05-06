
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/user.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDatasource {

  Future<AuthResult> login(String email, String passeord);

  Future<AuthResult> register(String name, String email, String password);

  Future<User> validateToken(String token);
}