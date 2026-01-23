import 'package:dio/dio.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';

import '../models/user_model.dart';

class AuthRemoteDatasource {
  final Dio dio;

  AuthRemoteDatasource(this.dio);

  Future<AuthResult> login(String email, String password,) async {
    final response = await dio.post('/auth/login', data: { "email": email, 'password' : password,},);
    
    return AuthResult(user: UserModel.fromJson(response.data['user']), token: response.data['access_token'],);
  }

  Future<AuthResult> register( String name, String email, String password,) async{
    final response = await dio.post('auth/register', data: {'name': name, 'email': email, 'password': password,},);

    return AuthResult(user: UserModel.fromJson(response.data['user']), token : response.data['access_token'],);
  }
}