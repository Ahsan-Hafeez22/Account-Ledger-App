import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/storage/secure_storage_datasource.dart';

class TokenStorageKeys {
  static const String accessToken = 'auth_access_token';
  static const String refreshToken = 'auth_refresh_token';
  static const String tokenExpiry = 'auth_token_expiry';
  static const String userId = 'auth_user_id';
}

abstract interface class TokenStorageDataSource {
  Future<void> storeAccessToken(String token, {bool persist = true});

  Future<String?> getAccessToken();

  /// Same as [storeAccessToken] for refresh token.
  Future<void> storeRefreshToken(String token, {bool persist = true});

  Future<String?> getRefreshToken();

  /// Clears both in-memory session and persisted storage. Call on logout
  /// or when tokens are invalidated (e.g. 401).
  Future<void> clearTokens();
}

class TokenStorageDataSourceImpl implements TokenStorageDataSource {
  TokenStorageDataSourceImpl({required SecureStorageDataSource secureStorage})
    : _secureStorage = secureStorage;

  final SecureStorageDataSource _secureStorage;

  /// In-memory session tokens (used when "remember me" is false).
  String? _sessionAccessToken;
  String? _sessionRefreshToken;

  @override
  Future<void> storeAccessToken(String token, {bool persist = true}) async {
    try {
      if (persist) {
        await _secureStorage.write(
          key: TokenStorageKeys.accessToken,
          value: token,
        );
        _sessionAccessToken = token;
      } else {
        await _secureStorage.delete(key: TokenStorageKeys.accessToken);
        _sessionAccessToken = token;
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to store access token',
        code: 'store-token-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      if (_sessionAccessToken != null && _sessionAccessToken!.isNotEmpty) {
        return _sessionAccessToken;
      }
      return await _secureStorage.read(key: TokenStorageKeys.accessToken);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get access token',
        code: 'get-token-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> storeRefreshToken(String token, {bool persist = true}) async {
    try {
      if (persist) {
        await _secureStorage.write(
          key: TokenStorageKeys.refreshToken,
          value: token,
        );
        _sessionRefreshToken = token;
      } else {
        await _secureStorage.delete(key: TokenStorageKeys.refreshToken);
        _sessionRefreshToken = token;
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to store refresh token',
        code: 'store-refresh-token-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      if (_sessionRefreshToken != null && _sessionRefreshToken!.isNotEmpty) {
        return _sessionRefreshToken;
      }
      return await _secureStorage.read(key: TokenStorageKeys.refreshToken);
    } catch (e) {
      throw CacheException(
        message: 'Failed to get refresh token',
        code: 'get-refresh-token-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> clearTokens() async {
    _sessionAccessToken = null;
    _sessionRefreshToken = null;
    try {
      await _secureStorage.delete(key: TokenStorageKeys.accessToken);
    } catch (_) {}
    try {
      await _secureStorage.delete(key: TokenStorageKeys.refreshToken);
    } catch (_) {}
  }
}
