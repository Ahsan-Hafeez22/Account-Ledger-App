import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/internet_checker.dart';
import 'package:dio/dio.dart';

/// Dio interceptor that fails the request with [NetworkException] when
/// there is no internet connectivity.
class DioInternetCheckInterceptor extends QueuedInterceptor {
  DioInternetCheckInterceptor({required InternetChecker internetChecker})
    : _internetChecker = internetChecker;

  final InternetChecker _internetChecker;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connected = await _internetChecker.isConnected;
    if (!connected) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NetworkException(
            message: 'No internet connection',
            code: 'no-internet',
          ),
        ),
      );
      return;
    }
    handler.next(options);
  }
}
