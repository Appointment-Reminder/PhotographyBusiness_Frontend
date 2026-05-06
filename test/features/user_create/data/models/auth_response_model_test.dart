import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/features/user_create/data/models/auth_result_model.dart';
import 'package:photography_business_frontend/features/user_create/data/models/user_model.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';

import '../../../../fixtures/fixture_reader.dart';

void main(){
  final tUserModel = UserModel(id: 1, name: 'test', email: 'test@test.com');
  final tAuthModel = AuthResultModel(token: 'test', user: tUserModel);

  test(
    'should be a subclass of UserEntity',
        () async {
      //assert
      expect(tAuthModel, isA<AuthResult>());
    },
  );

  group('fromJson', () {
    test(
        'Should return a a valid auth result model when the json is received',
            () async {
          //arrange
          final Map<String, dynamic> jsonMap = json.decode(fixture('user_login.json'));

          //act
          final result = AuthResultModel.fromJson(jsonMap);

          //assert
          expect(result, tAuthModel);
        }
    );
  });

  group('toJson', (){
    test(
        'Should return a JSON map containing the proper data',
            () async{
          //act
          final result = tAuthModel.toJson();
          //assert
          final expectedJsonMap = {
            "token": 'test',
            "user": {
              'id': 1,
              "name": "test",
              "email": "test@test.com"
            }
          };
          expect(result, expectedJsonMap);
        }
    );
  });
}