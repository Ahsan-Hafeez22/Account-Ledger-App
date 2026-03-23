import 'dart:io';

import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/interceptors/dio_auth_interceptor.dart';
import 'package:account_ledger/core/network/interceptors/dio_internet_check_interceptor.dart';
import 'package:account_ledger/core/network/interceptors/logging_interceptor.dart';
import 'package:account_ledger/core/network/internet_checker.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:dio/dio.dart';

class DioClient {
  DioClient({
    required String baseUrl,
    required InternetChecker internetChecker,
    required TokenStorageDataSource tokenStorage,
    Future<void> Function()? onUnauthorized,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _dio = Dio(
         BaseOptions(
          baseUrl: baseUrl,
           connectTimeout: connectTimeout,
           receiveTimeout: receiveTimeout,
           headers: {
             'Accept': 'application/json',
             'Content-Type': 'application/json',
           },
         ),
       ) {
    _dio.interceptors.addAll([
      DioInternetCheckInterceptor(internetChecker: internetChecker),
      DioAuthInterceptor(
        tokenStorage: tokenStorage,
        onUnauthorized: onUnauthorized,
      ),
      LoggingInterceptor(),
    ]);
  }

  final String _baseUrl;
  final Dio _dio;
  Dio get dio => _dio;

  String get baseUrl => _baseUrl;

  /// GET request. Returns decoded response body (e.g. [Map], [List]).
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _request(
      () => _dio.get(
        _path(endpoint),
        queryParameters: queryParameters,
        options: Options(headers: headers),
      ),
    );
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = true,
  }) async {
    return _request(
      () => _dio.post(
        _path(endpoint),
        data: body,
        options: Options(
          headers: headers,
          contentType: jsonBody && body is! FormData
              ? Headers.jsonContentType
              : null,
        ),
      ),
    );
  }

  Future<dynamic> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = true,
  }) async {
    return _request(
      () => _dio.put(
        _path(endpoint),
        data: body,
        options: Options(
          headers: headers,
          contentType: jsonBody && body is! FormData
              ? Headers.jsonContentType
              : null,
        ),
      ),
    );
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = true,
  }) async {
    return _request(
      () => _dio.patch(
        _path(endpoint),
        data: body,
        options: Options(
          headers: headers,
          contentType: jsonBody && body is! FormData
              ? Headers.jsonContentType
              : null,
        ),
      ),
    );
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool jsonBody = true,
  }) async {
    return _request(
      () => _dio.delete(
        _path(endpoint),
        data: body,
        options: Options(
          headers: headers,
          contentType: jsonBody && body is! FormData
              ? Headers.jsonContentType
              : null,
        ),
      ),
    );
  }

  Future<dynamic> uploadMultipart(
    String endpoint, {
    required String fieldName,
    dynamic files,
    Map<String, dynamic>? fields,
    Map<String, String>? headers,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData();

    // Add text fields
    if (fields != null) {
      formData.fields.addAll(
        fields.entries.map((e) => MapEntry(e.key, e.value.toString())),
      );
    }
    if (files != null) {
      final fileList = files is List ? files : [files];

      for (final item in fileList) {
        if (item == null) continue;

        if (item is MultipartFile) {
          formData.files.add(MapEntry(fieldName, item));
        } else if (item is String && item.isNotEmpty) {
          final path = item;
          final filename = path.split(Platform.pathSeparator).last;
          final multipartFile = await MultipartFile.fromFile(
            path,
            filename: filename,
          );
          formData.files.add(MapEntry(fieldName, multipartFile));
        } else {
          throw ArgumentError(
            'Unsupported file type: ${item.runtimeType}. '
            'Expected String (path) or MultipartFile.',
          );
        }
      }
    }

    // If no files were added → that's perfectly fine (optional file)

    return _request(
      () => _dio.post(
        _path(endpoint),
        data: formData,
        options: Options(headers: headers),
        onSendProgress: onSendProgress,
      ),
    );
  }

  String _path(String endpoint) {
    final path = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return path;
  }

  Future<dynamic> _request(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  dynamic _handleResponse(Response<dynamic> response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if (statusCode >= 200 && statusCode < 300) {
      return data;
    }

    final message =
        _extractMessage(data) ?? 'Request failed with status code $statusCode';

    if (statusCode == 401) {
      throw AuthException(
        message: message,
        code: 'unauthorized',
        details: data,
      );
    }

    if (statusCode == 422) {
      throw ValidationException(
        message: message,
        code: 'validation-failed',
        details: data,
      );
    }

    if (statusCode >= 400 && statusCode < 500) {
      throw ServerException(
        message: message,
        code: 'client-error-$statusCode',
        details: data,
      );
    }

    if (statusCode >= 500) {
      throw ServerException(
        message: message,
        code: 'server-error-$statusCode',
        details: data,
      );
    }

    throw ServerException(
      message: 'Unexpected response status code $statusCode',
      code: 'unexpected-status',
      details: data,
    );
  }

  AppException _mapDioException(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 401) {
      return AuthException(
        message: _extractMessage(data) ?? 'Unauthorized',
        code: 'unauthorized',
        details: data,
      );
    }

    if (statusCode == 422) {
      return ValidationException(
        message:
            _extractMessage(data) ??
            'Validation failed. Please check your input and try again.',
        code: 'validation-failed',
        details: data,
      );
    }

    if (statusCode != null && statusCode >= 400) {
      return ServerException(
        message: _extractMessage(data) ?? (e.message ?? 'Request failed'),
        code: 'client-error-$statusCode',
        details: data,
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(
        message: e.message ?? 'Network request failed',
        code: 'network-error',
        details: e.toString(),
      );
    }

    return NetworkException(
      message: e.message ?? 'Network request failed',
      code: 'http-error',
      details: e.toString(),
    );
  }

  String? _extractMessage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final errors = decoded['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty && value.first is String) {
            return value.first as String;
          }
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }
      if (decoded['message'] is String) return decoded['message'] as String;
      if (decoded['error'] is String) return decoded['error'] as String;
    }
    return null;
  }
}
