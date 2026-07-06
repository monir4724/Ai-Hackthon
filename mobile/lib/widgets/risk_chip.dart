import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class RiskChip extends StatelessWidget {
  const RiskChip({super.key, required this.riskLevel});

  final String riskLevel;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _style(riskLevel);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: AppTextStyles.monoLabel(10, color: color),
      ),
    );
  }

  (String, Color) _style(String risk) {
    switch (risk) {
      case 'high':
        return ('উচ্চ ঝুঁকি', AppColors.danger);
      case 'safe':
      case 'none':
        return ('নিরাপদ', AppColors.safe);
      case 'low':
      case 'medium':
      default:
        return ('সতর্ক', AppColors.accentOn);
    }
  }
}
