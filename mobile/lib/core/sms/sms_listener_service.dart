import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:uuid/uuid.dart';

import '../api/api_config.dart';
import '../api/api_models.dart';
import '../notifications/notification_service.dart';
import 'mfs_sms_filter.dart';
import 'pending_verdict_store.dart';

const _enabledKey = 'sms_auto_scan_enabled';
const _sessionKey = 'rokkhakoboch_session_id';
const _uuid = Uuid();

@pragma('vm:entry-point')
Future<void> smsBackgroundMessageHandler(SmsMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SmsListenerService.handleMessage(message);
}

/// Toggle-able Android SMS listener — finance-related messages only.
abstract final class SmsListenerService {
  static final Telephony _telephony = Telephony.instance;
  static bool _listening = false;

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<bool> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (!enabled) {
      await prefs.setBool(_enabledKey, false);
      await stop();
      return true;
    }

    final started = await start();
    if (started) {
      await prefs.setBool(_enabledKey, true);
      return true;
    }

    await prefs.setBool(_enabledKey, false);
    return false;
  }

  static Future<void> restoreIfEnabled() async {
    if (!Platform.isAndroid) return;
    if (await isEnabled()) {
      await start();
    }
  }

  static Future<bool> start() async {
    if (!Platform.isAndroid) return false;
    if (_listening) return true;

    final granted = await _telephony.requestPhoneAndSmsPermissions ?? false;
    if (!granted) return false;

    _telephony.listenIncomingSms(
      onNewMessage: handleMessage,
      onBackgroundMessage: smsBackgroundMessageHandler,
      listenInBackground: true,
    );
    _listening = true;
    return true;
  }

  static Future<void> stop() async {
    _listening = false;
  }

  static Future<void> handleMessage(SmsMessage message) async {
    if (!await isEnabled()) return;

    final body = message.body ?? '';
    final sender = message.address ?? '';
    if (!MfsSmsFilter.looksFinanceRelated(sender, body)) {
      return;
    }

    try {
      final result = await _analyze(body);
      if (result == null) return;

      final risk = result.riskLevel;
      if (risk != 'high' && risk != 'medium') return;

      final payload = VerdictPayload.fromAnalysis(
        result,
        inputText: body,
        sourceLabel: 'SMS অটো-স্ক্যান',
      );
      final verdictId = await PendingVerdictStore.save(payload);

      await NotificationService.showSmsRiskAlert(
        title: 'সন্দেহজনক এসএমএস সনাক্ত',
        body: result.verdictBn,
        verdictId: verdictId,
      );
    } catch (_) {
      // Intentionally silent — no SMS logging.
    }
  }

  static Future<AnalysisResult?> _analyze(String text) async {
    final prefs = await SharedPreferences.getInstance();
    var sessionId = prefs.getString(_sessionKey);
    sessionId ??= await _ensureSessionId(prefs);

    final client = http.Client();
    try {
      final res = await client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/analyze'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'text': text,
              'module': 'sms_auto',
              'session_id': sessionId,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (res.statusCode < 200 || res.statusCode >= 300) return null;
      return AnalysisResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } finally {
      client.close();
    }
  }

  static Future<String> _ensureSessionId(SharedPreferences prefs) async {
    final id = _uuid.v4();
    await prefs.setString(_sessionKey, id);
    return id;
  }
}
