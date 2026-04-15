// core/services/device_info_service.dart
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoService {
  static const _persistedDeviceIdKey = 'ledger_app_device_id';

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Backend expects camelCase: [deviceId], [fcmToken], [deviceType], [deviceName].
  /// Never throws: uses fallbacks when plugins are missing or FCM is unavailable.
  Future<Map<String, dynamic>> getDeviceData() async {
    var fcmToken = '';
    try {
      fcmToken = (await FirebaseMessaging.instance.getToken()) ?? '';
    } catch (_) {}

    var deviceId = '';
    var deviceName = '';
    var deviceType = '';

    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        deviceId = info.id;
        deviceName = info.model;
        deviceType = 'A';
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        deviceId = info.identifierForVendor ?? '';
        deviceName = info.utsname.machine;
        deviceType = 'I';
      } else {
        deviceType = Platform.operatingSystem;
        deviceName = Platform.operatingSystem;
      }
    } catch (_) {
      if (Platform.isAndroid) {
        deviceType = 'A';
      } else if (Platform.isIOS) {
        deviceType = 'I';
      } else {
        deviceType = Platform.operatingSystem;
      }
      deviceName = 'unknown';
      deviceId = '';
    }

    final resolvedId = await _ensureNonEmptyDeviceId(deviceId);
    final data = {
      'deviceId': resolvedId,
      'fcmToken': fcmToken,
      'deviceType': deviceType,
      'deviceName': deviceName.isEmpty ? 'unknown' : deviceName,
    };
    log(data.toString());
    return data;
  }

  Future<String> getDeviceIdForLogout() async {
    var deviceId = '';

    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        deviceId = info.id;
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        deviceId = info.identifierForVendor ?? '';
      } else {}
    } catch (_) {
      deviceId = '';
    }

    final resolvedId = await _ensureNonEmptyDeviceId(deviceId);
    return resolvedId;
  }

  Future<String> _ensureNonEmptyDeviceId(String fromPlatform) async {
    if (fromPlatform.isNotEmpty) return fromPlatform;
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_persistedDeviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    const uuid = Uuid();
    final generated = uuid.v4();
    await prefs.setString(_persistedDeviceIdKey, generated);
    return generated;
  }
}
