
import 'dart:convert';

import 'package:photography_business_frontend/features/user_create/data/models/user_model.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';

class AuthResultModel extends AuthResult {
  const AuthResultModel({
    required super.token,
    required super.user
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
        token: json['access_token'],
        user: UserModel.fromJson(json['user'])
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'token': token,
      'user': (user as UserModel).toJson(),
    };
  }
}