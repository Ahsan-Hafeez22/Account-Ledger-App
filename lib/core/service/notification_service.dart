import 'dart:convert';

import 'package:account_ledger/core/routes/route_names.dart';
import 'package:account_ledger/features/notification/data/models/app_notification_model.dart';
import 'package:account_ledger/features/notification/presentation/notification_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';

/// FCM + local notifications bridge (foreground display + tap/deeplink).
class NotificationService {
  static const _androidChannelId = 'account_ledger_default';
  static const _androidChannelName = 'Account Ledger';
  static const _androidChannelDescription = 'Account Ledger notifications';

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _local;

  GoRouter? _router;
  bool _initialized = false;

  NotificationService({
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _local = localNotifications ?? FlutterLocalNotificationsPlugin();

  Future<void> init({required GoRouter router, bool requestPermission = true}) async {
    _router = router;
    if (_initialized) return;
    _initialized = true;

    await _initLocalNotifications();
    if (requestPermission) {
      await ensurePermissions(promptIfNotGranted: true);
    }
    await _wireFcmHandlers();
  }

  Future<bool> ensurePermissions({required bool promptIfNotGranted}) async {
    try {
      // iOS / macOS
      final current = await _messaging.getNotificationSettings();
      final isGranted = current.authorizationStatus == AuthorizationStatus.authorized ||
          current.authorizationStatus == AuthorizationStatus.provisional;
      if (isGranted) return true;

      // Android 13+ uses runtime permission. Use local_notifications request API.
      final androidImpl =
          _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        if (promptIfNotGranted) {
          final allowed = await androidImpl.requestNotificationsPermission();
          return allowed ?? false;
        }
        return false;
      }

      if (!promptIfNotGranted) return false;
      final requested = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return requested.authorizationStatus == AuthorizationStatus.authorized ||
          requested.authorizationStatus == AuthorizationStatus.provisional;
    } catch (_) {
      return false;
    }
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        _handleTapFromPayload(payload);
      },
      onDidReceiveBackgroundNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        _handleTapFromPayload(payload);
      },
    );

    const channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDescription,
      importance: Importance.high,
    );

    final android =
        _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(channel);
  }

  Future<void> _wireFcmHandlers() async {
    // If launched by tapping a notification from terminated state.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleTapFromData(_normalizedData(initial.data));
    }

    // When app in background and user taps notification.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleTapFromData(_normalizedData(message.data));
    });

    // Foreground: show local notification.
    FirebaseMessaging.onMessage.listen((message) async {
      final data = _normalizedData(message.data);
      final title = message.notification?.title ?? (data['title'] as String?);
      final body = message.notification?.body ?? (data['body'] as String?);
      await showLocalNotification(
        title: title ?? 'Account Ledger',
        body: body ?? '',
        data: data,
      );
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      final payload = jsonEncode(data);
      final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);

      const androidDetails = AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails, iOS: DarwinNotificationDetails());

      await _local.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('showLocalNotification failed: $e');
    }
  }

  void _handleTapFromPayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _handleTapFromData(_normalizedData(Map<String, dynamic>.from(decoded)));
      }
    } catch (_) {}
  }

  void _handleTapFromData(Map<String, dynamic> data) {
    final router = _router;
    if (router == null) return;

    // Use the centralized routing logic.
    final model = AppNotificationModel(
      id: (data['_id'] ?? data['id'] ?? '').toString(),
      type: (data['type'] ?? '').toString(),
      title: (data['title'] ?? '').toString(),
      body: (data['body'] ?? '').toString(),
      imageUrl: data['imageUrl'] as String?,
      data: data,
      readAt: null,
      createdAt: DateTime.now(),
    );

    if (!NotificationRouter.canNavigate(model)) {
      router.go(RouteEndpoints.dashboard);
      return;
    }
    NotificationRouter.navigate(router.routerDelegate.navigatorKey.currentContext!, model);
  }

  Map<String, dynamic> _normalizedData(Map<String, dynamic> raw) {
    // Some servers send nested `data` JSON, others flatten. Normalize to a flat map.
    final out = <String, dynamic>{};
    for (final entry in raw.entries) {
      out[entry.key] = entry.value;
    }
    final nested = raw['data'];
    if (nested is String) {
      try {
        final decoded = jsonDecode(nested);
        if (decoded is Map) {
          for (final e in decoded.entries) {
            out[e.key.toString()] = e.value;
          }
        }
      } catch (_) {}
    } else if (nested is Map) {
      for (final e in nested.entries) {
        out[e.key.toString()] = e.value;
      }
    }
    return out;
  }
}

