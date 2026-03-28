import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_local_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/data/datasources/auth_remote_dataSource.dart';
import 'package:photography_business_frontend/features/user_create/data/models/auth_result_model.dart';
import 'package:photography_business_frontend/features/user_create/data/models/user_model.dart';
import 'package:photography_business_frontend/features/user_create/data/repositories/auth_repository_impl.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/auth_result.dart';
import 'package:photography_business_frontend/features/user_create/domain/entities/user.dart';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';


@GenerateMocks([AuthRemoteDatasource, AuthLocalDatasource, NetworkInfo])
import 'auth_repository_impl_test.mocks.dart';

void main(){
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDatasource mockRemoteDataSource;
  late MockAuthLocalDatasource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp((){
    mockRemoteDataSource = MockAuthRemoteDatasource();
    mockLocalDataSource = MockAuthLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    repository = AuthRepositoryImpl(mockRemoteDataSource, mockLocalDataSource, mockNetworkInfo);
  });

  group('user login',(){
    final temail = 'test@test.com';
    final tname = 'test';
    final tpassword = 'test';
    final ttoken = 'test_token';
    final tUserModel = UserModel(id: 1, email: temail, name: tname);
    final User tUser = tUserModel;

    test('should check network connection once when logging in', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      // act
      await repository.login(
        email: temail,
        password: tpassword,
      );

      // assert
      verify(mockNetworkInfo.isConnected).called(1);
    });


    test('should return AuthResult when login is successful and device is online', () async {
      //arrange
      final tAuthResult = AuthResult(user: tUser, token: ttoken);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.login(temail, tpassword)).thenAnswer((_) async => tAuthResult);

      // act
      final result = await repository.login(email: temail, password: tpassword);

      // assert
      expect(result, Right(tAuthResult));
      verify(mockRemoteDataSource.login(temail, tpassword)).called(1);
    });

    test('should return ServerFailure when device is offline', () async {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      //act
      final result = await repository.login(email: temail, password: tpassword);

      //assert
      expect(result, const Left(ServerFailure('No internet connection')));
      verifyNever(mockRemoteDataSource.login(any, any));
    });

    test('should return ServerFailure when credentials are invalid (401)', () async {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true );
      when(mockRemoteDataSource.login(temail, tpassword))
          .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path:''),
            statusCode: 401,
          )
      ));


      //act
      final result = await repository.login(email: temail, password: tpassword);

      //assert
      expect(result, const Left(ServerFailure('Wrong Credential')));
    });

    test('should return ServerFailure with message when other DIOException occurs', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.login(temail, tpassword))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path:''),
            message: 'Connection timeout',
      ));

      //act
      final result = await repository.login(email: temail, password: tpassword);

      //assert
      expect(result, const Left(ServerFailure('Connection timeout')));
    });

    test('should return ServerFailure when unexpected error occurs', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.login(temail, tpassword))
          .thenThrow(Exception('Something went wrong'));

      // act
      final result = await repository.login(email: temail, password: tpassword);

      // assert
      expect(result, const Left(ServerFailure('Unexpected error')));
    });

    test(
        'should save token and user locally when login is successful', () async {
      //arrange
      final tAuthResult = AuthResult(user: tUser, token: ttoken);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.login(temail, tpassword))
          .thenAnswer((_) async => tAuthResult);
      when(mockLocalDataSource.cacheUserLogin(any)).thenAnswer((_) async =>
          Future.value());

      //act
      await repository.login(email: temail, password: tpassword);

      //asset
      verify(mockLocalDataSource.cacheUserLogin(tAuthResult)).called(1);
    });

    test('should not cache locally when login fails', () async {
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.login(temail, tpassword))
          .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 401,
          )));

      //act
      await repository.login(email: temail, password: tpassword);

      //assert
      verifyNever(mockLocalDataSource.cacheUserLogin(any));
    });
  });


  group('check auth status',() {
    final tToken = 'saved_token';
    final temail = 'test@test.com';
    final tname = 'test';
    final tUserModel = UserModel(id: 1, email: temail, name: tname);
    final User tUser = tUserModel;
    final tAuthResult = AuthResult(user: tUser, token: tToken);

    test('should return CacheFailure when no cached login data exists', () async {
      //arrange
      when(mockLocalDataSource.getCachedUserLogin()).thenAnswer((_) async => null);
      
      // act
      final result = await repository.checkAuthStatus();
      
      //assert
      expect(result, const Left(CacheFailure('No saved session')));
      verifyNever(mockNetworkInfo.isConnected);
    });
    
    test('should validate token with backend when online', () async {
      //arrange
      when(mockLocalDataSource.getCachedUserLogin()).thenAnswer((_) async => tAuthResult);
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.validateToken(tToken))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 401,
        ),
      ));

      //act
      final result = await repository.checkAuthStatus();

      // assert
      expect(result, const Left(CacheFailure('Failed to restore session')));
    });

    test('should return CacheFailure when unexpected error occurs', () async {
      // arrange
      when(mockLocalDataSource.getCachedUserLogin())
          .thenThrow(Exception('Cache error'));

      // act
        final result = await repository.checkAuthStatus();

        // assert
      expect(result, const Left(CacheFailure('Failed to restore session')));
    });
  });


  group('user register', () {
    final tEmail = 'newuser@test.com';
    final tName = 'New User';
    final tPassword = 'password123';
    final tUserModel = UserModel(id: 2, email: tEmail, name: tName);
    final User tUser = tUserModel;
    final tAuthResult = AuthResult(user: tUser, token: 'new_token');

    test('should check network connection once when registering', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.register(tName, tEmail, tPassword))
          .thenAnswer((_) async => tAuthResult);
      when(mockLocalDataSource.cacheUserLogin(any))
          .thenAnswer((_) async => Future.value());

      // act
      await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      verify(mockNetworkInfo.isConnected).called(1);
    });

    test('should return ServerFailure when device is offline', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // act
      final result = await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, const Left(ServerFailure('No internet connection')));
      verifyNever(mockRemoteDataSource.register(any, any, any));
    });

    test('should return AuthResult when registration is successful', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.register(tName, tEmail, tPassword))
          .thenAnswer((_) async => tAuthResult);
      when(mockLocalDataSource.cacheUserLogin(any))
          .thenAnswer((_) async => Future.value());

      // act
      final result = await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, Right(tAuthResult));
      verify(mockRemoteDataSource.register(tName, tEmail, tPassword)).called(1);
    });

    test('should cache user login data when registration is successful', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.register(tName, tEmail, tPassword))
          .thenAnswer((_) async => tAuthResult);
      when(mockLocalDataSource.cacheUserLogin(any))
          .thenAnswer((_) async => Future.value());

      // act
      await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      verify(mockLocalDataSource.cacheUserLogin(tAuthResult)).called(1);
    });

    test('should return ServerFailure when email already exists (409)', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.register(tName, tEmail, tPassword))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 409,
        ),
      ));

      // act
      final result = await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, const Left(ServerFailure('Email already exists')));
    });

    test('should return ServerFailure when input data is invalid (422)', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.register(tName, tEmail, tPassword))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 422,
        ),
      ));

      // act
      final result = await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, const Left(ServerFailure('Invalid input data')));
    });

    test('should not cache locally when registration fails', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.register(tName, tEmail, tPassword))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 409,
        ),
      ));

      // act
      await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      verifyNever(mockLocalDataSource.cacheUserLogin(any));
    });

    test('should return ServerFailure with message when other DioException occurs', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.register(tName, tEmail, tPassword))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Connection timeout',
      ));

      // act
      final result = await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, const Left(ServerFailure('Connection timeout')));
    });

    test('should return ServerFailure when unexpected error occurs', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.register(tName, tEmail, tPassword))
          .thenThrow(Exception('Something went wrong'));

      // act
      final result = await repository.register(
        name: tName,
        email: tEmail,
        password: tPassword,
      );

      // assert
      expect(result, const Left(ServerFailure('Unexpected error')));
    });
  });
}