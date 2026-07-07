import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/forensic_label.dart';
import '../widgets/paper_card.dart';
import '../widgets/screen_shell.dart';

class _PermissionItem {
  const _PermissionItem({
    required this.title,
    required this.explanation,
    required this.checkStatus,
    this.settingsHint,
  });

  final String title;
  final String explanation;
  final Future<PermissionCheckResult> Function() checkStatus;
  final String? settingsHint;
}

class PermissionCheckResult {
  const PermissionCheckResult(this.label, this.color);
  final String label;
  final Color color;
}

class DeviceProtectionScreen extends StatefulWidget {
  const DeviceProtectionScreen({super.key});

  @override
  State<DeviceProtectionScreen> createState() => _DeviceProtectionScreenState();
}

class _DeviceProtectionScreenState extends State<DeviceProtectionScreen> {
  late final List<_PermissionItem> _items;
  final Map<String, PermissionCheckResult> _results = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _items = [
      _PermissionItem(
        title: 'SMS পড়া/পাঠানো',
        explanation:
            'SMS পড়ার অনুমতি থাকা অ্যাপ OTP চুরি করতে পারে — স্ক্যাম অ্যাপগুলো আপনার ব্যাংকিং কোড পড়ে নিতে পারে।',
        checkStatus: () => _mapPermission(Permission.sms),
        settingsHint: 'সেটিংস → অ্যাপ → রক্ষাকবচ → অনুমতি → SMS',
      ),
      _PermissionItem(
        title: 'অন্য অ্যাপের উপর দেখানো (Overlay)',
        explanation:
            'অন্য অ্যাপের উপরে দেখানোর অনুমতি ফিশিং ওভারলে তৈরি করতে ব্যবহৃত হয় — ভুয়া bKash স্ক্রিন দেখাতে পারে।',
        checkStatus: () => _mapPermission(Permission.systemAlertWindow),
        settingsHint: 'সেটিংস → অ্যাপ → রক্ষাকবচ → অন্য অ্যাপের উপর দেখান',
      ),
      _PermissionItem(
        title: 'অজানা অ্যাপ ইনস্টল',
        explanation:
            'অজানা উৎস থেকে অ্যাপ ইনস্টলের অনুমতি ম্যালওয়্যার ও স্ক্যাম অ্যাপ ঢোকাতে সাহায্য করে।',
        checkStatus: () => _mapPermission(Permission.requestInstallPackages),
        settingsHint: 'সেটিংস → অ্যাপ → বিশেষ অ্যাক্সেস → অজানা অ্যাপ ইনস্টল',
      ),
      _PermissionItem(
        title: 'অ্যাক্সেসিবিলিটি সেবা',
        explanation:
            'অ্যাক্সেসিবিলিটি সেবা স্ক্যাম অ্যাপকে স্ক্রিন পড়তে ও ক্লিক স্বয়ংক্রিয় করতে দেয় — সেটিংসে ম্যানুয়াল যাচাই করুন।',
        checkStatus: () async => const PermissionCheckResult('ম্যানুয়াল যাচাই', AppColors.outline),
        settingsHint: 'সেটিংস → অ্যাক্সেসিবিলিটি',
      ),
    ];
    _refresh();
  }

  Future<PermissionCheckResult> _mapPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) {
      return const PermissionCheckResult('অনুমতি দেওয়া', AppColors.danger);
    }
    if (status.isDenied) {
      return const PermissionCheckResult('অনুমতি নেই', AppColors.safe);
    }
    if (status.isPermanentlyDenied) {
      return const PermissionCheckResult('স্থায়ীভাবে বন্ধ', AppColors.safe);
    }
    if (status.isRestricted || status.isLimited) {
      return const PermissionCheckResult('প্রযোজ্য নয়', AppColors.outline);
    }
    return const PermissionCheckResult('অনুমতি নেই', AppColors.safe);
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    for (final item in _items) {
      _results[item.title] = await item.checkStatus();
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rokkhakobochAppBar('ডিভাইস সুরক্ষা'),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                PaperCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'এই স্ক্রিন শুধুমাত্র শিক্ষামূলক সচেতনতার জন্য — এটি অন্য অ্যাপ স্ক্যান করে না। '
                          'শুধুমাত্র রক্ষাকবচ অ্যাপের নিজের অনুমতি চেকলিস্ট দেখানো হয়।',
                          style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const ForensicLabel('মডিউল ০৭ — ডিভাইস সুরক্ষা চেকলিস্ট'),
                const SizedBox(height: 12),
                ...[
                  'অজানা উৎস থেকে APK ইনস্টল করবেন না (নকল bKash/Nagad অ্যাপ)',
                  'কাউকে SMS পড়ার অনুমতি দেবেন না',
                  'স্ক্রিন শেয়ার করবেন না (ফোন স্ক্যাম)',
                  'Accessibility-তে অজানা অ্যাপ যোগ করবেন না',
                  'অজানা নম্বর থেকে OTP কখনো দেবেন না',
                  'bKash/Nagad/Rocket কখনো PIN ফোনে চায় না',
                ].map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('• $tip', style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(height: 8),
                ..._items.map((item) {
                  final result = _results[item.title]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: PaperCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(item.title, style: AppTextStyles.tiroHeadline(16)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: result.color),
                                  color: result.color.withValues(alpha: 0.08),
                                ),
                                child: Text(
                                  result.label,
                                  style: AppTextStyles.monoLabel(10, color: result.color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.explanation,
                            style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant),
                          ),
                          if (item.settingsHint != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              item.settingsHint!,
                              style: AppTextStyles.monoLabel(10, color: AppColors.outline),
                            ),
                          ],
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: openAppSettings,
                            icon: const Icon(Icons.settings),
                            label: const Text('সেটিংসে যান'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('আবার যাচাই করুন'),
                ),
              ],
            ),
    );
  }
}
