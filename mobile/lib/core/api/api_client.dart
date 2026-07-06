import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_models.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<AnalysisResult> analyzeText({
    required String text,
    String module = 'sms',
    String? sessionId,
  }) async {
    try {
      final res = await _client
          .post(
            _uri('/analyze'),
            headers: _headers,
            body: jsonEncode({
              'text': text,
              'module': module,
              'session_id': ?sessionId,
            }),
          )
          .timeout(ApiConfig.timeout);
      _ensureOk(res);
      return AnalysisResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw const ApiException(0, 'নেটওয়ার্ক সংযোগ ব্যর্থ — ব্যাকএন্ড চালু আছে কিনা দেখুন।');
    } on http.ClientException {
      throw const ApiException(0, 'সার্ভারে সংযোগ করা যায়নি।');
    }
  }

  Future<UrlCheckResult> checkUrl(String url) async {
    try {
      final res = await _client
          .post(
            _uri('/url-check'),
            headers: _headers,
            body: jsonEncode({'url': url}),
          )
          .timeout(ApiConfig.timeout);
      _ensureOk(res);
      return UrlCheckResult.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
    } on SocketException {
      throw const ApiException(0, 'নেটওয়ার্ক সংযোগ ব্যর্থ — ব্যাকএন্ড চালু আছে কিনা দেখুন।');
    } on http.ClientException {
      throw const ApiException(0, 'সার্ভারে সংযোগ করা যায়নি।');
    }
  }

  Future<List<ScamPattern>> fetchReports({bool communityOnly = false}) async {
    try {
      final path = communityOnly ? '/reports?community_only=1' : '/reports';
      final res = await _client.get(_uri(path), headers: _headers).timeout(ApiConfig.timeout);
      _ensureOk(res);
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];
      return data.map((e) => ScamPattern.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      throw const ApiException(0, 'নেটওয়ার্ক সংযোগ ব্যর্থ।');
    } on http.ClientException {
      throw const ApiException(0, 'সার্ভারে সংযোগ করা যায়নি।');
    }
  }

  Future<ScamPattern> submitReport({
    required String textBn,
    String? category,
    String? locationLabel,
    String riskLevel = 'high',
  }) async {
    try {
      final res = await _client
          .post(
            _uri('/reports'),
            headers: _headers,
            body: jsonEncode({
              'text_bn': textBn,
              'category': ?category,
              'location_label': ?locationLabel,
              'risk_level': riskLevel,
            }),
          )
          .timeout(ApiConfig.timeout);
      _ensureOk(res);
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      return ScamPattern.fromJson(json['data'] as Map<String, dynamic>);
    } on SocketException {
      throw const ApiException(0, 'নেটওয়ার্ক সংযোগ ব্যর্থ।');
    } on http.ClientException {
      throw const ApiException(0, 'সার্ভারে সংযোগ করা যায়নি।');
    }
  }

  Future<List<ScanHistoryItem>> fetchHistory(String sessionId) async {
    try {
      final res = await _client
          .get(_uri('/history/$sessionId'), headers: _headers)
          .timeout(ApiConfig.timeout);
      _ensureOk(res);
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>? ?? [];
      return data.map((e) => ScanHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      throw const ApiException(0, 'নেটওয়ার্ক সংযোগ ব্যর্থ।');
    } on http.ClientException {
      throw const ApiException(0, 'সার্ভারে সংযোগ করা যায়নি।');
    }
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'API ত্রুটি (${res.statusCode})';
      try {
        final json = jsonDecode(res.body);
        if (json is Map && json['message'] != null) {
          message = json['message'].toString();
        }
      } catch (_) {}
      throw ApiException(res.statusCode, message);
    }
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
