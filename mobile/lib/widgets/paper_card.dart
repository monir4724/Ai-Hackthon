import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// White evidence card with ledger border — mirrors web .paper-card
class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: child,
    );
  }
}
