import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/features/authentication/data/models/user_model.dart';

const String _cachedUserKey = 'cached_user';

abstract class AuthLocalDatasource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SharedPreferences sharedPreferences;

  const AuthLocalDatasourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonString = json.encode(user.toJson());
    await sharedPreferences.setString(_cachedUserKey, jsonString);
  }

  @override
  Future<UserModel> getCachedUser() {
    final jsonString = sharedPreferences.getString(_cachedUserKey);
    if (jsonString == null) {
      throw CacheException(message: 'Failed to getCachedUser');
    }
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    return Future.value(UserModel.fromJson(jsonMap));
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedUserKey);
  }
}
