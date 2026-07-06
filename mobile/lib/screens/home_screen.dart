import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/screen_shell.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rokkhakobochAppBar(
        'রক্ষাকবচ',
        actions: [
          IconButton(
            tooltip: 'সেটিংস',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'টাকা হারানোর আগেই ধরা পড়বে',
              style: AppTextStyles.tiroHeadline(28),
            ),
            const SizedBox(height: 12),
            Text(
              'বাংলা স্ক্যাম মেসেজ, লিংক ও QR স্ক্যান করুন — AI-চালিত ঝুঁকি বিশ্লেষণ।',
              style: AppTextStyles.siliguriBody(16, color: AppColors.onSurfaceVariant),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ScanScreen()),
              ),
              icon: const Icon(Icons.fact_check),
              label: const Text('এখনই স্ক্যান করুন'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
              icon: const Icon(Icons.sms_outlined),
              label: const Text('SMS অটো-স্ক্যান সেটিংস'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
