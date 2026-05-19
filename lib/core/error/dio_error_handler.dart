import 'package:dio/dio.dart';

import 'failure.dart';

class DioErrorHandler {
  static Failure handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return ServerFailure(e.response?.data['detail'] ?? 'Bad request');
      case 401:
        return const ServerFailure('Unauthorized - Please login again');
      case 403:
        return const ServerFailure('Forbidden - You don\'t have permission');
      case 404:
        return const ServerFailure('Not found');
      case 409:
        return ServerFailure(e.response?.data['detail'] ?? 'Conflict - Resource already exists');
      case 422:
        return ServerFailure(e.response?.data['detail'] ?? 'Invalid input data');
      case 500:
        return const ServerFailure('Internal server error');
      case 503:
        return const ServerFailure('Service unavailable');
      default:
        return ServerFailure(e.message ?? 'Server error');
    }
  }
}