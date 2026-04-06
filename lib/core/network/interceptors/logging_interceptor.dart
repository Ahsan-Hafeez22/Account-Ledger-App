import 'package:dio/dio.dart';
import 'package:account_ledger/core/utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  static const _sensitiveKeys = {
    'authorization',
    'token',
    'access_token',
    'refresh_token',
    'password',
    'pin',
    'pincode',
    'oldpin',
    'newpin',
    'api_key',
    'apikey',
    'secret',
  };

  Map<String, dynamic> _maskMap(Map<String, dynamic> map) {
    final masked = <String, dynamic>{};
    for (final entry in map.entries) {
      final key = entry.key.toLowerCase();
      if (_sensitiveKeys.any((s) => key.contains(s))) {
        masked[entry.key] = '***';
        continue;
      }
      masked[entry.key] = entry.value;
    }
    return masked;
  }

  dynamic _safeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return _maskMap(data);
    }
    return data;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final safeHeaders = _maskMap(Map<String, dynamic>.from(options.headers));
    logger.i(
      'REQUEST[${options.method}] => PATH: ${options.uri}\n'
      'Headers: $safeHeaders\n'
      'Data: ${_safeData(options.data)}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.uri}\n'
      'Data: ${_safeData(response.data)}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.uri}\n'
      'Message: ${err.message}',
    );
    handler.next(err);
  }
}
