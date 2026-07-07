class FlagBn {
  const FlagBn({
    required this.key,
    required this.labelBn,
    required this.explanationBn,
  });

  final String key;
  final String labelBn;
  final String explanationBn;

  factory FlagBn.fromJson(Map<String, dynamic> json) {
    return FlagBn(
      key: json['key'] as String? ?? '',
      labelBn: json['label_bn'] as String? ?? '',
      explanationBn: json['explanation_bn'] as String? ?? '',
    );
  }
}

class PrefilterResult {
  const PrefilterResult({
    required this.riskScore,
    required this.flags,
    required this.matchedPatterns,
    this.flagCount = 0,
  });

  final int riskScore;
  final List<String> flags;
  final List<String> matchedPatterns;
  final int flagCount;

  factory PrefilterResult.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PrefilterResult(riskScore: 0, flags: [], matchedPatterns: []);
    }
    return PrefilterResult(
      riskScore: json['risk_score'] as int? ?? 0,
      flags: (json['flags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      matchedPatterns:
          (json['matched_patterns'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      flagCount: json['flag_count'] as int? ?? 0,
    );
  }
}

class AnalysisResult {
  const AnalysisResult({
    required this.riskLevel,
    required this.verdictBn,
    required this.explanation,
    required this.matchedPattern,
    this.confidence,
    this.disclaimer,
    this.module,
    this.analyzedAt,
    this.scamCategory,
    this.aiSource,
    this.prefilter,
  });

  final String riskLevel;
  final String verdictBn;
  final String explanation;
  final String matchedPattern;
  final String? scamCategory;
  final String? confidence;
  final String? disclaimer;
  final String? module;
  final String? analyzedAt;
  final String? aiSource;
  final PrefilterResult? prefilter;

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      riskLevel: json['risk_level'] as String? ?? 'medium',
      verdictBn: json['verdict_bn'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      matchedPattern: json['matched_pattern'] as String? ?? '',
      confidence: json['confidence'] as String?,
      disclaimer: json['disclaimer'] as String?,
      module: json['module'] as String?,
      analyzedAt: json['analyzed_at'] as String?,
      aiSource: json['ai_source'] as String?,
      scamCategory: json['scam_category'] as String? ??
          (json['prefilter'] as Map<String, dynamic>?)?['scam_category'] as String?,
      prefilter: PrefilterResult.fromJson(json['prefilter'] as Map<String, dynamic>?),
    );
  }
}

class ScamPattern {
  const ScamPattern({
    required this.id,
    required this.category,
    required this.label,
    required this.riskLevel,
    required this.textBn,
    required this.isCommunityReport,
    required this.createdAt,
    this.redFlagsBn,
    this.locationLabel,
  });

  final int id;
  final String category;
  final String label;
  final String riskLevel;
  final String textBn;
  final String? redFlagsBn;
  final String? locationLabel;
  final bool isCommunityReport;
  final String createdAt;

  factory ScamPattern.fromJson(Map<String, dynamic> json) {
    return ScamPattern(
      id: json['id'] as int,
      category: json['category'] as String? ?? '',
      label: json['label'] as String? ?? '',
      riskLevel: json['risk_level'] as String? ?? '',
      textBn: json['text_bn'] as String? ?? '',
      redFlagsBn: json['red_flags_bn'] as String?,
      locationLabel: json['location_label'] as String?,
      isCommunityReport: json['is_community_report'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class ScanHistoryItem {
  const ScanHistoryItem({
    required this.id,
    required this.sessionId,
    required this.module,
    required this.inputText,
    required this.riskLevel,
    required this.createdAt,
    this.matchedPattern,
    this.explanation,
  });

  final int id;
  final String sessionId;
  final String module;
  final String inputText;
  final String riskLevel;
  final String? matchedPattern;
  final String? explanation;
  final String createdAt;

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id'] as int,
      sessionId: json['session_id'] as String? ?? '',
      module: json['module'] as String? ?? '',
      inputText: json['input_text'] as String? ?? '',
      riskLevel: json['risk_level'] as String? ?? '',
      matchedPattern: json['matched_pattern'] as String?,
      explanation: json['explanation'] as String?,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class UrlCheckResult {
  const UrlCheckResult({
    required this.riskLevel,
    required this.verdictBn,
    required this.flags,
    required this.explanation,
    required this.disclaimer,
    this.riskScore,
    this.flagsBn = const [],
  });

  final String riskLevel;
  final String verdictBn;
  final List<String> flags;
  final List<FlagBn> flagsBn;
  final String explanation;
  final String disclaimer;
  final int? riskScore;

  factory UrlCheckResult.fromJson(Map<String, dynamic> json) {
    return UrlCheckResult(
      riskLevel: json['risk_level'] as String? ?? 'medium',
      verdictBn: json['verdict_bn'] as String? ?? '',
      flags: (json['flags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      flagsBn: (json['flags_bn'] as List<dynamic>? ?? [])
          .map((e) => FlagBn.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: json['explanation'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? '',
      riskScore: json['risk_score'] as int?,
    );
  }
}

class QrCheckResult extends UrlCheckResult {
  const QrCheckResult({
    required super.riskLevel,
    required super.verdictBn,
    required super.flags,
    required super.explanation,
    required super.disclaimer,
    super.riskScore,
    super.flagsBn,
    this.scamCategory,
  });

  final String? scamCategory;

  factory QrCheckResult.fromJson(Map<String, dynamic> json) {
    return QrCheckResult(
      riskLevel: json['risk_level'] as String? ?? 'medium',
      verdictBn: json['verdict_bn'] as String? ?? '',
      flags: (json['flags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      flagsBn: (json['flags_bn'] as List<dynamic>? ?? [])
          .map((e) => FlagBn.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: json['explanation'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? '',
      riskScore: json['risk_score'] as int?,
      scamCategory: json['scam_category'] as String?,
    );
  }
}

/// Unified verdict display for ResultScreen (analyze + url-check).
class VerdictPayload {
  const VerdictPayload({
    required this.riskLevel,
    required this.verdictBn,
    required this.explanation,
    required this.disclaimer,
    this.matchedPattern,
    this.inputPreview,
    this.flags = const [],
    this.prefilter,
    this.aiSource,
    this.sourceLabel,
    this.scamCategory,
    this.riskScore,
    this.flagsBn = const [],
  });

  final String riskLevel;
  final String verdictBn;
  final String explanation;
  final String disclaimer;
  final String? matchedPattern;
  final String? inputPreview;
  final List<String> flags;
  final List<FlagBn> flagsBn;
  final PrefilterResult? prefilter;
  final String? aiSource;
  final String? sourceLabel;
  final String? scamCategory;
  final int? riskScore;

  factory VerdictPayload.fromAnalysis(AnalysisResult result, {String? inputText, String? sourceLabel}) {
    return VerdictPayload(
      riskLevel: result.riskLevel,
      verdictBn: result.verdictBn,
      explanation: result.explanation,
      disclaimer: result.disclaimer ?? VerdictPayload.defaultDisclaimer,
      matchedPattern: result.matchedPattern,
      inputPreview: inputText,
      prefilter: result.prefilter,
      aiSource: result.aiSource,
      sourceLabel: sourceLabel ?? 'মেসেজ বিশ্লেষণ',
      scamCategory: result.scamCategory,
    );
  }

  factory VerdictPayload.fromUrlCheck(UrlCheckResult result, {required String url}) {
    return VerdictPayload(
      riskLevel: result.riskLevel,
      verdictBn: result.verdictBn,
      explanation: result.explanation,
      disclaimer: result.disclaimer,
      matchedPattern: result.flags.isNotEmpty ? result.flags.join(', ') : 'URL স্ক্যান',
      inputPreview: url,
      flags: result.flags,
      flagsBn: result.flagsBn,
      riskScore: result.riskScore,
      sourceLabel: 'লিংক নিরাপত্তা যাচাই',
    );
  }

  factory VerdictPayload.fromQrCheck(QrCheckResult result, {required String payload}) {
    return VerdictPayload(
      riskLevel: result.riskLevel,
      verdictBn: result.verdictBn,
      explanation: result.explanation,
      disclaimer: result.disclaimer,
      inputPreview: payload,
      flags: result.flags,
      flagsBn: result.flagsBn,
      riskScore: result.riskScore,
      scamCategory: result.scamCategory ?? 'আর্থিক/QR প্রতারণা',
      sourceLabel: 'QR / পেমেন্ট যাচাই',
    );
  }

  static const defaultDisclaimer =
      'এটি ১০০% নিশ্চিত নয় — এটি একটি ঝুঁকি নির্দেশক টুল';

  Map<String, dynamic> toJson() => {
        'risk_level': riskLevel,
        'verdict_bn': verdictBn,
        'explanation': explanation,
        'disclaimer': disclaimer,
        'matched_pattern': matchedPattern,
        'input_preview': inputPreview,
        'flags': flags,
        'ai_source': aiSource,
        'source_label': sourceLabel,
      };

  factory VerdictPayload.fromJson(Map<String, dynamic> json) {
    return VerdictPayload(
      riskLevel: json['risk_level'] as String? ?? 'medium',
      verdictBn: json['verdict_bn'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? defaultDisclaimer,
      matchedPattern: json['matched_pattern'] as String?,
      inputPreview: json['input_preview'] as String?,
      flags: (json['flags'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      aiSource: json['ai_source'] as String?,
      sourceLabel: json['source_label'] as String?,
    );
  }
}
