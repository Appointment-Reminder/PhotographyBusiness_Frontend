import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:mockito/annotations.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_remote_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_remote_dataSource_Impl.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/user.dart';

@GenerateMocks([Dio])

import 'auth_remote_data_source_test.mocks.dart';



void main(){
  late AuthRemoteDatasourceImpl remoteDatasource;
  late MockDio mockDio;

  setUp((){
    mockDio = MockDio();
    remoteDatasource = AuthRemoteDatasourceImpl(mockDio);
  });

  group('login', (){
    final tEmail = 'test@test.com';
    final tPassword = 'password123';
    final tToken = 'test_token_12345';
    final tUserJson = {
      'id' : 1,
      'email' : tEmail,
      'name': 'Test User'
    };
    final tResponseData = {
      'user': tUserJson,
      'access_token': tToken
    };

    test('should perform POST request to /auth/login endpoint with form data', () async {
      // arrange
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options'),))
          .thenAnswer((_) async => Response(data: tResponseData, statusCode: 200, requestOptions: RequestOptions(path: '/auth/login'),));

      // act
      await remoteDatasource.login(tEmail, tPassword);

      // assert
      verify(mockDio.post(
        '/auth/login',
        data: {
          'username': tEmail,
          'password': tPassword,
          'grant_type': 'password',
        },
        options: argThat(
          isA<Options>().having(
                (o) => o.contentType,
            'contentType',
            Headers.formUrlEncodedContentType,
          ),
          named: 'options',
        ),
      )).called(1);
    });

    test('Should return AuthResult when response is successful (200)', () async {
      when(mockDio.post(any, data: anyNamed('data'), options: anyNamed('options'),))
          .thenAnswer((_) async => Response(data: tResponseData, statusCode: 200, requestOptions: RequestOptions(path: '/auth/login'),));


      //act
      final result = await remoteDatasource.login(tEmail, tPassword);

      //assert
      expect(result, isA<AuthResult>());
      expect(result.token, tToken);
      expect(result.user.email, tEmail);
      expect(result.user.name, 'Test User');
    });

    test('Should throw DioException when server returns error', () async {
      //arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
      ));

      //act
      final call = remoteDatasource.login(tEmail, tPassword);

      //assert
      expect(() => call, throwsA(isA<DioException>()));
    });


  });

  group('register', (){
    final tName = 'New User';
    final tEmail = 'newuser@test.com';
    final tPassword = 'password123';
    final tToken = 'new_token_12345';
    final tUserJson = {
      'id': 2,
      'email': tEmail,
      'name': tName,
    };
    final tResponseData = {
      'user': tUserJson,
      'access_token': tToken,
    };

    test('should perform POST request to /auth/register endpoint', () async {
      // arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: tResponseData,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/auth/register'),
      ));

      // act
      await remoteDatasource.register(tName, tEmail, tPassword);

      // assert
      verify(mockDio.post(
        '/auth/register',
        data: {'name': tName, 'email': tEmail, 'password': tPassword},
      )).called(1);
    });

    test('should return AuthResult when registration is successful (201)', () async {
      // arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        data: tResponseData,
        statusCode: 201,
        requestOptions: RequestOptions(path: '/auth/register'),
      ));

      // act
      final result = await remoteDatasource.register(tName, tEmail, tPassword);

      // assert
      expect(result, isA<AuthResult>());
      expect(result.token, tToken);
      expect(result.user.email, tEmail);
      expect(result.user.name, tName);
    });

    test('should throw DioException when email already exists (409)', () async {
      // arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        response: Response(
          statusCode: 409,
          requestOptions: RequestOptions(path: '/auth/register'),
        ),
      ));

      // act
      final call = remoteDatasource.register(tName, tEmail, tPassword);

      // assert
      expect(() => call, throwsA(isA<DioException>()));
    });

    test('should throw DioException when input is invalid (422)', () async {
      // arrange
      when(mockDio.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/register'),
        response: Response(
          statusCode: 422,
          requestOptions: RequestOptions(path: '/auth/register'),
        ),
      ));

      // act
      final call = remoteDatasource.register(tName, tEmail, tPassword);

      // assert
      expect(() => call, throwsA(isA<DioException>()));
    });
  });

  group('validateTOken', (){
    final tToken = 'valid_token_12345';
    final tUserJson = {
      'id': 1,
      'email': 'test@test.com',
      'name': 'Test User',
    };

    test('should perform GET request to /auth/validate with Authorization header', () async {
      // arrange
      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: tUserJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/validate'),
      ));

      // act
      await remoteDatasource.validateToken(tToken);

      // assert
      verify(mockDio.get(
        '/auth/validate',
        options: argThat(
          isA<Options>().having(
                (o) => o.headers?['Authorization'],
            'Authorization header',
            'Bearer $tToken',
          ),
          named: 'options',
        ),
      )).called(1);
    });

    test('should return User when token is valid (200)', () async {
      // arrange
      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
        data: tUserJson,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/validate'),
      ));

      // act
      final result = await remoteDatasource.validateToken(tToken);

      // assert
      expect(result, isA<User>());
      expect(result.email, 'test@test.com');
      expect(result.name, 'Test User');
    });

    test('should throw DioException when token is invalid (401)', () async {
      // arrange
      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/validate'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/auth/validate'),
        ),
      ));

      // act
      final call = remoteDatasource.validateToken(tToken);

      // assert
      expect(() => call, throwsA(isA<DioException>()));
    });
  });

}