import 'package:dio/dio.dart';

import '../errors/api_exception.dart';

class ApiErrorMapper {
  static ApiException mapDioException(
    DioException exception, {
    required String fallbackMessage,
  }) {
    return ApiException(
      message: _extractApiMessage(exception) ?? fallbackMessage,
      statusCode: exception.response?.statusCode,
    );
  }

  static String? _extractApiMessage(DioException exception) {
    final responseData = exception.response?.data;

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      if (message is List) {
        final joined = message
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .join(', ');
        if (joined.isNotEmpty) {
          return joined;
        }
      }
    }

    return null;
  }
}
