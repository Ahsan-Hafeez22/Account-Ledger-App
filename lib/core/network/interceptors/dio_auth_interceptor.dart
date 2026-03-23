import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:dio/dio.dart';

class DioAuthInterceptor extends QueuedInterceptor {
  DioAuthInterceptor({
    required TokenStorageDataSource tokenStorage,
    Future<void> Function()? onUnauthorized,
  }) : _tokenStorage = tokenStorage,
       _onUnauthorized = onUnauthorized;

  final TokenStorageDataSource _tokenStorage;
  final Future<void> Function()? _onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers.putIfAbsent('Authorization', () => 'Bearer $token');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 401) {
      await _handleUnauthorized(
        AuthException(
          message: 'Session expired. Please log in again.',
          code: 'unauthorized',
          details: {'uri': response.requestOptions.uri.toString()},
        ),
      );
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: AuthException(
            message: 'Session expired. Please log in again.',
            code: 'unauthorized',
            details: response.data,
          ),
        ),
      );
      return;
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    if (statusCode == 401) {
      await _handleUnauthorized(
        AuthException(
          message: err.response?.data is Map
              ? (err.response!.data['message'] ?? 'Unauthorized').toString()
              : 'Session expired. Please log in again.',
          code: 'unauthorized',
          details: err.response?.data,
        ),
      );
    }
    handler.next(err);
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
