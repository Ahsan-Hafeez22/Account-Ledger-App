import 'package:account_ledger/core/error/exceptions.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorageDataSource {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<bool> containsKey({required String key});
  Future<void> deleteAll();
  Future<Map<String, String>> readAll();
}

class SecureStorageDataSourceImpl implements SecureStorageDataSource {
  final FlutterSecureStorage _secureStorage;

  SecureStorageDataSourceImpl({FlutterSecureStorage? secureStorage})
    : _secureStorage =
          secureStorage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      throw CacheException(
        message: 'Failed to write to secure storage',
        code: 'storage-write-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      return await _secureStorage.read(key: key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to read from secure storage',
        code: 'storage-read-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to delete from secure storage',
        code: 'storage-delete-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    try {
      return await _secureStorage.containsKey(key: key);
    } catch (e) {
      throw CacheException(
        message: 'Failed to check key in secure storage',
        code: 'storage-check-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to clear secure storage',
        code: 'storage-clear-failed',
        details: e.toString(),
      );
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      return await _secureStorage.readAll();
    } catch (e) {
      throw CacheException(
        message: 'Failed to read all from secure storage',
        code: 'storage-read-all-failed',
        details: e.toString(),
      );
    }
  }
}
