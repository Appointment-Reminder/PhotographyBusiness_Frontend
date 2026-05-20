
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_remote_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/data/models/user_model.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/user.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio client;

  AuthRemoteDatasourceImpl(this.client);

  @override
  Future<AuthResult> login(String email, String password) async {
    final response = await client.post('/users/token',
      data: {
        'username': email,  // OAuth2 uses 'username', not 'email'
        'password': password,
        'grant_type': 'password',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,  // Important!
      ),
    );

    return AuthResult(
      user: UserModel.fromJson(response.data['user']),
      token: response.data['access_token'],
    );
  }

  @override
  Future<AuthResult> register( String name, String email, String password,) async{
    final response = await client.post('/users', data: {'name': name, 'email': email, 'password': password,},);
    
    final loginResponse = await client.post(
      '/users/token',
      data: {
        'username': email,
        'password': password,
        'grant_type': 'password',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    return AuthResult(
      user: UserModel.fromJson(loginResponse.data['user']),
      token: loginResponse.data['access_token'],
    );
  }

  @override
  Future<User> validateToken(String token) async {
    print('Validate token to server');
    final response = await client.get(
      '/users/me',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    print('🔵 Response: ${response.data}');

    return UserModel.fromJson(response.data);
  }

}