import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/user.dart';
import 'package:photography_business_frontend/features/user_create/domain/repositories/auth_repository.dart';
import 'package:photography_business_frontend/features/user_create/domain/usecases/login_user.dart';

import 'login_user_test.mocks.dart';


@GenerateMocks([AuthRepository])
void main(){
  late LoginUser usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUser(mockAuthRepository);
  });

  final temail = 'test@com';
  final tname = 'test';
  final tpassword ='test';
  final tUser = User(name: "test", email: "test@com", id: 1);
  final tAuthResponse = AuthResult(user: tUser, token: "test");

  test(
    'should get auth response for the login from the repository',
      () async {
        when(mockAuthRepository.login(
          email: temail,
          password: tpassword,
        )).thenAnswer((_) async => Right(tAuthResponse));

        final result = await usecase.call(
            LoginParams(email: temail, password: tpassword));

        expect(result, Right(tAuthResponse));
        verify(mockAuthRepository.login(email: temail, password: tpassword));
        verifyNoMoreInteractions(mockAuthRepository);
      },
  );
}