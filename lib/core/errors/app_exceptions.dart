class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  final List<dynamic>? errors;

  AppException(this.message, {this.code, this.statusCode, this.errors});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([super.message = 'Unable to connect to server. Please check your connection.'])
      : super(code: 'NETWORK_ERROR');
}

class AuthException extends AppException {
  AuthException(super.message, {String? code})
      : super(code: code ?? 'AUTH_ERROR', statusCode: 401);
}

class ValidationException extends AppException {
  ValidationException(super.message, {super.errors})
      : super(code: 'VALIDATION_ERROR', statusCode: 400);
}

class NotFoundException extends AppException {
  NotFoundException(super.message)
      : super(code: 'NOT_FOUND', statusCode: 404);
}

class ServerException extends AppException {
  ServerException([super.message = 'An unexpected server error occurred. Please try again.'])
      : super(code: 'SERVER_ERROR', statusCode: 500);
}
