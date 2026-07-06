import 'package:flutter/material.dart';

import '../core/data/bangladesh_divisions.dart';
import '../core/api/api_client.dart';
import '../core/api/app_services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/async_state.dart';
import '../widgets/forensic_label.dart';
import '../widgets/paper_card.dart';
import '../widgets/screen_shell.dart';
import '../widgets/verdict_seal.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _textController = TextEditingController();
  final _categoryController = TextEditingController();
  String? _selectedDivision;
  bool _loading = false;
  bool _success = false;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.length < 10) {
      setState(() => _error = 'কমপক্ষে ১০ অক্ষর লিখুন');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AppServices.api.submitReport(
        textBn: text,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        locationLabel: _selectedDivision,
      );
      if (!mounted) return;
      setState(() {
        _success = true;
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'রিপোর্ট জমা দিতে ব্যর্থ।';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        appBar: rokkhakobochAppBar('রিপোর্ট করুন'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const VerdictSeal(
                  riskLevel: 'safe',
                  verdictBn: 'ধন্যবাদ',
                  showDisclaimer: false,
                ),
                const SizedBox(height: 24),
                const Icon(Icons.check_circle, color: AppColors.safe, size: 64),
                const SizedBox(height: 16),
                Text(
                  'এটি অন্যদের সুরক্ষায় সাহায্য করবে।',
                  style: AppTextStyles.tiroHeadline(20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                PaperCard(
                  child: Text(
                    'আপনার রিপোর্ট সফলভাবে আমাদের ফরেনসিক ডাটাবেসে জমা হয়েছে।',
                    style: AppTextStyles.siliguriBody(15, color: AppColors.onSurfaceVariant),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('ফিডে ফিরে যান'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: rokkhakobochAppBar('রিপোর্ট করুন'),
      body: _loading
          ? const LoadingView(message: 'জমা দিচ্ছে...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'সন্দেহজনক মেসেজ বা কল সম্পর্কে তথ্য দিয়ে অন্যদের সাহায্য করুন।',
                    style: AppTextStyles.siliguriBody(16, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  PaperCard(
                    child: Row(
                      children: [
                        const Icon(Icons.privacy_tip, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'আপনার নাম প্রকাশ করা হবে না',
                            style: AppTextStyles.monoLabel(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PaperCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ForensicLabel('স্ক্যামের ধরন / ক্যাটাগরি'),
                        TextField(
                          controller: _categoryController,
                          decoration: const InputDecoration(
                            hintText: 'যেমন: OTP phishing',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ForensicLabel('মেসেজ বা কল ডিটেইলস *'),
                        TextField(
                          controller: _textController,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'সন্দেহজনক মেসেজটি এখানে কপি করুন...',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ForensicLabel('বিভাগ (ঐচ্ছিক)'),
                        DropdownButtonFormField<String?>(
                          initialValue: _selectedDivision,
                          decoration: const InputDecoration(
                            hintText: 'বিভাগ নির্বাচন করুন',
                            border: UnderlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('উল্লেখ করবেন না'),
                            ),
                            ...BangladeshDivisions.names.map(
                              (name) => DropdownMenuItem<String?>(
                                value: name,
                                child: Text(name),
                              ),
                            ),
                          ],
                          onChanged: (value) => setState(() => _selectedDivision = value),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!, style: const TextStyle(color: AppColors.danger)),
                        ],
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.flag),
                          label: const Text('রিপোর্ট জমা দিন'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.accentOn,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
