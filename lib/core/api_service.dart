import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://api.themoviedb.org/3';

  ApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer [IMDB_Access_Token]',
    };

    // Add interceptors for logging, error handling, etc.
    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.get(endpoint, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleError(e);
    }
  }

  dynamic _handleResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        return response.data;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
        throw UnauthorizedException(response.data.toString());
      case 403:
        throw UnauthorizedException(response.data.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occurred while communicating with server with status code : ${response.statusCode}');
    }
  }

  dynamic _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw FetchDataException('Timeout Error: ${error.message}');
      case DioExceptionType.badResponse:
        return _handleResponse(error.response!);
      case DioExceptionType.cancel:
        throw FetchDataException('Request was cancelled');
      case DioExceptionType.unknown:
        throw FetchDataException('Unexpected error occurred');
      default:
        throw FetchDataException('Oops something went wrong');
    }
  }
}

// Custom exceptions
class AppException implements Exception {
  final String? message;
  final String? prefix;

  AppException([this.message, this.prefix]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorizedException extends AppException {
  UnauthorizedException([message]) : super(message, "Unauthorized: ");
}
