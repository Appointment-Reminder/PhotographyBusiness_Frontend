
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/features/user_create/data/models/user_model.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/user.dart';

import '../../../../fixtures/fixture_reader.dart';

void main(){
  final tUserModel = UserModel(id: 1, name: 'test', email: 'test@test.com');

  test(
    'should be a subclass of UserEntity',
      () async {
      //assert
      expect(tUserModel, isA<User>());
      },
  );

  group('fromJson', () {
    test(
      'Should return a avalid user model when the json is received',
        () async {
          //arrange
          final Map<String, dynamic> jsonMap = json.decode(fixture('user.json'));

          //act
          final result = UserModel.fromJson(jsonMap);

          //assert
          expect(result, tUserModel);
        }
    );
  });

  group('toJson', (){
    test(
      'Should return a JSON map containing the proper data',
        () async{
        //act
          final result = tUserModel.toJson();
          //assert
          final expectedJsonMap = {
            'id': 1,
            "name": "test",
            "email": "test@test.com"
          };
          expect(result, expectedJsonMap);
        }
    );
  });
}