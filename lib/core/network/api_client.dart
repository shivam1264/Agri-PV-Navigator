import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import '../errors/app_exceptions.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? code;
  final List<dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
    this.errors,
  });
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();
  VoidCallback? onUnauthorized;

  String get baseUrl => AppConfig.baseUrl;

  Future<Map<String, String>> _buildHeaders({bool requiresAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path, queryParams);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      return _client.get(uri, headers: headers).timeout(AppConfig.requestTimeout);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> post(String path, {dynamic body, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      return _client
          .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(AppConfig.requestTimeout);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> patch(String path, {dynamic body, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      return _client
          .patch(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(AppConfig.requestTimeout);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> put(String path, {dynamic body, bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      return _client
          .put(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
          .timeout(AppConfig.requestTimeout);
    }, requiresAuth: requiresAuth);
  }

  Future<dynamic> delete(String path, {bool requiresAuth = true}) async {
    return _sendWithRetry(() async {
      final uri = _buildUri(path);
      final headers = await _buildHeaders(requiresAuth: requiresAuth);
      return _client.delete(uri, headers: headers).timeout(AppConfig.requestTimeout);
    }, requiresAuth: requiresAuth);
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final urlStr = '$baseUrl$cleanPath';
    final parsed = Uri.parse(urlStr);

    if (queryParams != null && queryParams.isNotEmpty) {
      final stringParams = queryParams.map((k, v) => MapEntry(k, v.toString()));
      return parsed.replace(queryParameters: stringParams);
    }

    return parsed;
  }

  Future<dynamic> _sendWithRetry(
    Future<http.Response> Function() requestFn, {
    bool requiresAuth = true,
  }) async {
    try {
      final response = await requestFn();

      if (response.statusCode == 401 && requiresAuth) {
        // Attempt token refresh
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          // Retry original request once
          final retryResponse = await requestFn();
          return _handleResponse(retryResponse);
        } else {
          onUnauthorized?.call();
          throw AuthException('Session expired. Please log in again.');
        }
      }

      return _handleResponse(response);
    } on SocketException catch (_) {
      throw NetworkException();
    } on http.ClientException catch (_) {
      throw NetworkException();
    } on AppException {
      rethrow;
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw NetworkException('Request timed out. Please try again.');
      }
      throw ServerException(e.toString());
    }
  }

  Future<bool> _attemptTokenRefresh() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final refreshUri = Uri.parse('$baseUrl/api/auth/refresh');
      final res = await _client.post(
        refreshUri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final tokens = data['data']['tokens'];
        await TokenStorage.saveTokens(
          accessToken: tokens['accessToken'],
          refreshToken: tokens['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      debugPrint('[ApiClient] Token refresh failed: $e');
    }
    return false;
  }

  dynamic _handleResponse(http.Response response) {
    dynamic jsonBody;
    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (jsonBody is Map<String, dynamic> && jsonBody.containsKey('data')) {
        return jsonBody['data'];
      }
      return jsonBody;
    }

    final message = jsonBody is Map<String, dynamic>
        ? (jsonBody['message'] ?? 'An error occurred')
        : 'Server returned error status ${response.statusCode}';
    final code = jsonBody is Map<String, dynamic> ? jsonBody['code'] : null;
    final errors = jsonBody is Map<String, dynamic> ? jsonBody['errors'] : null;

    switch (response.statusCode) {
      case 400:
        throw ValidationException(message, errors: errors);
      case 401:
        throw AuthException(message, code: code);
      case 404:
        throw NotFoundException(message);
      case 409:
        throw AppException(message, code: 'CONFLICT', statusCode: 409);
      default:
        throw ServerException(message);
    }
  }
}
