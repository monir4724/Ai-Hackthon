import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../notifications/notification_service.dart';
import '../sms/sms_listener_service.dart';
import 'api_client.dart';
import 'session_service.dart';

/// App-wide API + session access (initialized in main).
abstract final class AppServices {
  static late final ApiClient api;
  static late final SessionService session;

  static Future<void> init({bool skipPushAndSms = false}) async {
    final prefs = await SharedPreferences.getInstance();
    session = SessionService(prefs);
    api = ApiClient();

    if (skipPushAndSms) return;

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    await NotificationService.init(prefs);
    await SmsListenerService.restoreIfEnabled();
  }
}
