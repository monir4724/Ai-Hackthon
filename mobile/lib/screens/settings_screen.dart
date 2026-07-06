import 'dart:io';

import 'package:flutter/material.dart';

import '../core/sms/sms_listener_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/paper_card.dart';
import '../widgets/screen_shell.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _smsAutoScan = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await SmsListenerService.isEnabled();
    if (!mounted) return;
    setState(() {
      _smsAutoScan = enabled;
      _loading = false;
    });
  }

  Future<void> _onSmsToggle(bool value) async {
    setState(() {
      _smsAutoScan = value;
      _statusMessage = null;
    });

    final ok = await SmsListenerService.setEnabled(value);
    if (!ok && value) {
      if (!mounted) return;
      setState(() {
        _smsAutoScan = false;
        _statusMessage = 'SMS অনুমতি দেওয়া হয়নি — সেটিংস থেকে অনুমতি চালু করুন।';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rokkhakobochAppBar('সেটিংস'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!Platform.isAndroid)
                  PaperCard(
                    child: Text(
                      'SMS অটো-স্ক্যান শুধুমাত্র Android-এ উপলব্ধ। iOS এসএমএস পড়ার অনুমতি দেয় না।',
                      style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant),
                    ),
                  )
                else ...[
                  Text(
                    'চালু করলে, ব্যাংক/এমএফএস সম্পর্কিত এসএমএস স্বয়ংক্রিয়ভাবে বিশ্লেষণ করা হবে। '
                    'অন্য কোনো এসএমএস পড়া বা সংরক্ষণ করা হয় না।',
                    style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  PaperCard(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('SMS অটো-স্ক্যান চালু করুন', style: AppTextStyles.tiroHeadline(16)),
                      subtitle: Text(
                        'ডিফল্ট: বন্ধ',
                        style: AppTextStyles.monoLabel(11, color: AppColors.outline),
                      ),
                      value: _smsAutoScan,
                      activeThumbColor: AppColors.accent,
                      onChanged: _onSmsToggle,
                    ),
                  ),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(_statusMessage!, style: const TextStyle(color: AppColors.danger)),
                  ],
                ],
              ],
            ),
    );
  }
}
