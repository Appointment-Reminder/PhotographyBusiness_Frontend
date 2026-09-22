import 'package:dio/dio.dart';

import 'failure.dart';

class DioErrorHandler {
  static Failure handleError(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        return ServerFailure(_detail(e, 'Bad request'));
      case 401:
        return const ServerFailure('Unauthorized - Please login again');
      case 403:
        return const ServerFailure('Forbidden - You don\'t have permission');
      case 404:
        return const ServerFailure('Not found');
      case 409:
        return ServerFailure(_detail(e, 'Conflict - Resource already exists'));
      case 422:
        return ServerFailure(_detail(e, 'Invalid input data'));
      case 500:
        return const ServerFailure('Internal server error');
      case 503:
        return const ServerFailure('Service unavailable');
      default:
        return ServerFailure(e.message ?? 'Server error');
    }
  }

  static String _detail(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          final loc = (first['loc'] as List?)?.last;
          return loc != null ? '$loc: ${first['msg']}' : '${first['msg']}';
        }
      }
    }
    return fallback;
  }
}