import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Physical ink stamp at -6° — mirrors frontend VerdictStamp.tsx
class VerdictSeal extends StatelessWidget {
  const VerdictSeal({
    super.key,
    required this.riskLevel,
    required this.verdictBn,
    this.showDisclaimer = true,
    this.size = VerdictSealSize.large,
  });

  final String riskLevel;
  final String verdictBn;
  final bool showDisclaimer;
  final VerdictSealSize size;

  static const String disclaimer =
      'এটি ১০০% নিশ্চিত নয় — এটি একটি ঝুঁকি নির্দেশক টুল';

  _SealStyle get _style {
    switch (riskLevel) {
      case 'high':
        return const _SealStyle(AppColors.danger, AppColors.danger);
      case 'safe':
        return const _SealStyle(AppColors.safe, AppColors.safe);
      case 'medium':
      case 'low':
      default:
        return const _SealStyle(AppColors.accent, AppColors.accentOn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final fontSize = size == VerdictSealSize.large ? 36.0 : 20.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: -6 * math.pi / 180,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.05),
              border: Border.all(color: style.borderColor, width: 4),
            ),
            child: Text(
              verdictBn,
              style: AppTextStyles.tiroHeadline(fontSize, weight: FontWeight.bold)
                  .copyWith(color: style.color, letterSpacing: 0.5),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'প্রাথমিক ফরেনসিক রিপোর্ট',
          style: AppTextStyles.monoLabel(11, letterSpacing: 2),
        ),
        if (showDisclaimer) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              disclaimer,
              style: AppTextStyles.monoLabel(11, color: AppColors.onSurfaceVariant)
                  .copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

enum VerdictSealSize { large, small }

class _SealStyle {
  const _SealStyle(this.color, this.borderColor);
  final Color color;
  final Color borderColor;
}
