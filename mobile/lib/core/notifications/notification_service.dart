import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_models.dart';
import '../sms/pending_verdict_store.dart';

const _channelId = 'rokkhakoboch_alerts';
const _smsChannelId = 'rokkhakoboch_sms_alerts';
const _channelName = 'স্ক্যাম সতর্কতা';
const _smsChannelName = 'SMS সতর্কতা';
const _fcmTokenKey = 'rokkhakoboch_fcm_token';

typedef VerdictNavigationHandler = void Function(VerdictPayload payload);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

/// Firebase Cloud Messaging + local notifications (FCM + SMS risk alerts).
abstract final class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static SharedPreferences? _prefs;
  static String? _fcmToken;
  static VerdictNavigationHandler? _onVerdictNavigation;

  static String? get fcmToken => _fcmToken;

  static void setVerdictNavigationHandler(VerdictNavigationHandler handler) {
    _onVerdictNavigation = handler;
  }

  static Future<void> init(SharedPreferences prefs) async {
    _prefs = prefs;
    _fcmToken = prefs.getString(_fcmTokenKey);

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _initLocalNotifications();
    await _requestPermissions();
    await _configureFcm();
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'নতুন স্ক্যাম সতর্কতা ও হুমকি আপডেট',
          importance: Importance.high,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _smsChannelId,
          _smsChannelName,
          description: 'SMS অটো-স্ক্যান সতর্কতা',
          importance: Importance.max,
        ),
      );
    }
  }

  static Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      return;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (kDebugMode) {
      debugPrint('FCM permission: ${settings.authorizationStatus}');
    }
  }

  static Future<void> _configureFcm() async {
    await _refreshToken();

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
    _messaging.onTokenRefresh.listen(_persistToken);

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleOpenedMessage(initial);
    }
  }

  static Future<void> _refreshToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _persistToken(token);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token fetch failed: $e');
      }
    }
  }

  static Future<void> _persistToken(String token) async {
    _fcmToken = token;
    await _prefs?.setString(_fcmTokenKey, token);
    if (kDebugMode) {
      debugPrint('FCM token: $token');
    }
  }

  static Future<void> showSmsRiskAlert({
    required String title,
    required String body,
    required String verdictId,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _smsChannelId,
        _smsChannelName,
        channelDescription: 'SMS অটো-স্ক্যান সতর্কতা',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _localNotifications.show(
      verdictId.hashCode,
      title,
      body,
      details,
      payload: 'sms_verdict:$verdictId',
    );
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'নতুন স্ক্যাম সতর্কতা ও হুমকি আপডেট',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'রক্ষাকবচ সতর্কতা',
      notification.body ?? '',
      details,
      payload: message.data['route'],
    );
  }

  static Future<void> _onNotificationTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || !payload.startsWith('sms_verdict:')) return;

    final verdictId = payload.substring('sms_verdict:'.length);
    final verdict = await PendingVerdictStore.load(verdictId);
    if (verdict == null) return;

    _onVerdictNavigation?.call(verdict);
    await PendingVerdictStore.delete(verdictId);
  }

  static void _handleOpenedMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('Opened from notification: ${message.messageId} data=${message.data}');
    }
  }
}
