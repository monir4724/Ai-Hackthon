import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../api/api_models.dart';

/// Stores analysis results for notification deep-links (no SMS content stored).
abstract final class PendingVerdictStore {
  static const _prefix = 'pending_verdict_';
  static const _uuid = Uuid();

  static Future<String> save(VerdictPayload payload) async {
    final id = _uuid.v4();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$id', jsonEncode(payload.toJson()));
    return id;
  }

  static Future<VerdictPayload?> load(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$id');
    if (raw == null) return null;
    try {
      return VerdictPayload.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$id');
  }
}
