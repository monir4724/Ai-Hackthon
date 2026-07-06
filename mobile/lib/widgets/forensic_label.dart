import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// IBM Plex Mono uppercase label for forensic data fields.
class ForensicLabel extends StatelessWidget {
  const ForensicLabel(
    this.text, {
    super.key,
    this.color,
    this.letterSpacing = 2,
  });

  final String text;
  final Color? color;
  final double letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.monoLabel(
        11,
        color: color ?? AppColors.outline,
        letterSpacing: letterSpacing,
      ),
    );
  }
}
