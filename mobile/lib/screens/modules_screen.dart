import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/forensic_label.dart';
import '../widgets/paper_card.dart';
import '../widgets/screen_shell.dart';
import 'deepfake_check_screen.dart';
import 'device_protection_screen.dart';
import 'qr_scan_screen.dart';
import 'threat_intel_hub_screen.dart';
import 'url_check_screen.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  static const _modules = [
    _ModuleInfo('01', 'এমএফএস মেসেজ সেন্টিনেল', 'সক্রিয়', active: true),
    _ModuleInfo('02', 'কল ট্রান্সক্রিপ্ট বিশ্লেষণ', 'সক্রিয়', active: true),
    _ModuleInfo('03', 'URL/ফিশিং লিংক গার্ড', 'সক্রিয়', active: true, route: _ModuleRoute.urlCheck),
    _ModuleInfo('04', 'আর্থিক প্রতারণা শিল্ড', 'সক্রিয়', active: true, route: _ModuleRoute.qrScan),
    _ModuleInfo('05', 'সোশ্যাল মিডিয়া স্ক্যাম ওয়াচ', 'শীঘ্রই আসছে'),
    _ModuleInfo('06', 'ডিপফেক/মিডিয়া ভেরিফিকেশন', 'পরীক্ষামূলক', active: true, route: _ModuleRoute.deepfake),
    _ModuleInfo('07', 'ডিভাইস সুরক্ষা', 'সক্রিয়', active: true, route: _ModuleRoute.deviceProtection),
    _ModuleInfo('08', 'পরিচয় সুরক্ষা', 'শীঘ্রই আসছে'),
    _ModuleInfo('09', 'ব্যবসায়িক সুরক্ষা', 'শীঘ্রই আসছে'),
    _ModuleInfo('10', 'জাতীয় হুমকি বুদ্ধিমত্তা', 'সক্রিয়', active: true, route: _ModuleRoute.threatIntel),
  ];

  void _openModule(BuildContext context, _ModuleInfo module) {
    final Widget screen;
    switch (module.route) {
      case _ModuleRoute.urlCheck:
        screen = const UrlCheckScreen();
      case _ModuleRoute.qrScan:
        screen = const QrScanScreen();
      case _ModuleRoute.deviceProtection:
        screen = const DeviceProtectionScreen();
      case _ModuleRoute.threatIntel:
        screen = const ThreatIntelHubScreen();
      case _ModuleRoute.deepfake:
        screen = const DeepfakeCheckScreen();
      case _ModuleRoute.none:
        return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rokkhakobochAppBar('১০-মডিউল সুরক্ষা'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ForensicLabel('জাতীয় সাইবার ডিফেন্স — কমান্ড সেন্টার'),
          const SizedBox(height: 8),
          Text('১০-মডিউল সুরক্ষা আর্কিটেকচার', style: AppTextStyles.tiroHeadline(24)),
          const SizedBox(height: 16),
          ..._modules.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: m.route != _ModuleRoute.none ? () => _openModule(context, m) : null,
                child: PaperCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.number,
                        style: AppTextStyles.monoLabel(22, color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.title, style: AppTextStyles.tiroHeadline(16)),
                            const SizedBox(height: 4),
                            Text(m.status, style: AppTextStyles.monoLabel(11, color: AppColors.outline)),
                          ],
                        ),
                      ),
                      if (m.route != _ModuleRoute.none)
                        const Icon(Icons.chevron_right, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ModuleRoute { none, urlCheck, qrScan, deviceProtection, threatIntel, deepfake }

class _ModuleInfo {
  const _ModuleInfo(
    this.number,
    this.title,
    this.status, {
    this.active = false,
    this.route = _ModuleRoute.none,
  });

  final String number;
  final String title;
  final String status;
  final bool active;
  final _ModuleRoute route;
}
