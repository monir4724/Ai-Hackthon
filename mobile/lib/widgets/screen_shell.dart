import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

PreferredSizeWidget rokkhakobochAppBar(String title, {List<Widget>? actions}) {
  return AppBar(
    title: Text(title),
    actions: actions,
    bottom: const PreferredSize(
      preferredSize: Size.fromHeight(1),
      child: Divider(height: 1, color: AppColors.outlineVariant),
    ),
  );
}

Widget emptyShellBody({required String message}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
      ),
    ),
  );
}
