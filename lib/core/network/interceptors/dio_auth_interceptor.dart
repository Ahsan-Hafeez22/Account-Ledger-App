import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:dio/dio.dart';

class DioAuthInterceptor extends QueuedInterceptor {
  DioAuthInterceptor({
    required TokenStorageDataSource tokenStorage,
    required Dio dio,
    Future<void> Function()? onUnauthorized,
  }) : _tokenStorage = tokenStorage,
       _dio = dio,
       _onUnauthorized = onUnauthorized;

  final TokenStorageDataSource _tokenStorage;
  final Dio _dio;
  final Future<void> Function()? _onUnauthorized;

  Future<void>? _refreshing;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      handler.next(options);
      return;
    }
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;
    final alreadyRetried = requestOptions.extra['retried'] == true;
    final skipAuth = requestOptions.extra['skipAuth'] == true;

    if (statusCode == 401 && !alreadyRetried && !skipAuth) {
      try {
        await _refreshTokensSingleFlight();
        final newToken = await _tokenStorage.getAccessToken();
        final cloned = await _retryRequest(requestOptions, newToken);
        handler.resolve(cloned);
        return;
      } catch (_) {
        await _handleUnauthorized(
          AuthException(
            message: 'Session expired. Please log in again.',
            code: 'unauthorized',
            details: err.response?.data,
          ),
        );
        handler.next(err);
        return;
      }
    }

    handler.next(err);
  }

  Future<void> _refreshTokensSingleFlight() async {
    final existing = _refreshing;
    if (existing != null) return existing;

    final refresh = _doRefresh();
    _refreshing = refresh;
    try {
      await refresh;
    } finally {
      if (identical(_refreshing, refresh)) {
        _refreshing = null;
      }
    }
  }

  Future<void> _doRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const AuthException(message: 'Missing refresh token', code: 'no-refresh-token');
    }

    // Use a short-lived client without interceptors so refresh is never blocked
    // by the same QueuedInterceptor / error chain that triggered it, and so a
    // failed user call cannot prevent the refresh HTTP request from being sent.
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: _dio.options.baseUrl,
        connectTimeout: _dio.options.connectTimeout,
        receiveTimeout: _dio.options.receiveTimeout,
        headers: Map<String, dynamic>.from(_dio.options.headers),
      ),
    );
    try {
      final response = await refreshDio.post<dynamic>(
        ApiEndpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
          'refresh_token': refreshToken,
        },
      );
      final data = response.data;
      if (data is! Map) {
        throw const ServerException(
          message: 'Invalid refresh response',
          code: 'invalid-refresh-response',
        );
      }
      final map = Map<String, dynamic>.from(data);
      final access = (map['accessToken'] ??
              map['access_token'] ??
              map['token'] ??
              '') as String;
      final rotatedRefresh = (map['refreshToken'] ?? map['refresh_token'] ?? '') as String;
      if (access.isEmpty) {
        throw const ServerException(
          message: 'Missing access token in refresh response',
          code: 'missing-access-after-refresh',
        );
      }
      await _tokenStorage.storeAccessToken(access);
      // Many APIs only return a new access token and keep the same refresh token.
      if (rotatedRefresh.isNotEmpty) {
        await _tokenStorage.storeRefreshToken(rotatedRefresh);
      }
    } finally {
      refreshDio.close();
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String? token,
  ) async {
    final headers = Map<String, dynamic>.from(requestOptions.headers);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    final options = Options(
      method: requestOptions.method,
      headers: headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      extra: Map<String, dynamic>.from(requestOptions.extra)..['retried'] = true,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  Future<void> _handleUnauthorized(AuthException error) async {
    try {
      await _tokenStorage.clearTokens();
    } catch (_) {
      // Ignore cache errors
    }
    final callback = _onUnauthorized;
    if (callback != null) {
      await callback();
    }
  }
}
