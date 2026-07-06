import 'package:flutter/material.dart';

import '../core/api/api_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/forensic_label.dart';
import '../widgets/paper_card.dart';
import '../widgets/screen_shell.dart';
import '../widgets/verdict_seal.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.payload});

  final VerdictPayload payload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rokkhakobochAppBar('বিশ্লেষণ ফলাফল'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (payload.sourceLabel != null) ...[
              ForensicLabel(payload.sourceLabel!),
              const SizedBox(height: 12),
            ],
            Center(
              child: VerdictSeal(
                riskLevel: payload.riskLevel,
                verdictBn: payload.verdictBn,
                showDisclaimer: false,
              ),
            ),
            const SizedBox(height: 8),
            if (payload.matchedPattern != null && payload.matchedPattern!.isNotEmpty) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    payload.matchedPattern!,
                    style: AppTextStyles.monoLabel(11, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            PaperCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ব্যাখ্যা', style: AppTextStyles.tiroHeadline(18)),
                  const SizedBox(height: 8),
                  Text(
                    payload.explanation,
                    style: AppTextStyles.siliguriBody(16, color: AppColors.onSurfaceVariant),
                  ),
                  if (payload.flags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const ForensicLabel('লাল পতাকা'),
                    const SizedBox(height: 8),
                    ...payload.flags.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $f', style: AppTextStyles.monoLabel(12)),
                      ),
                    ),
                  ],
                  if (payload.prefilter != null && payload.prefilter!.flags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const ForensicLabel('প্রি-ফিল্টার'),
                    const SizedBox(height: 8),
                    ...payload.prefilter!.flags.map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('• $f', style: AppTextStyles.monoLabel(12)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (payload.inputPreview != null) ...[
              const SizedBox(height: 12),
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ForensicLabel('মূল ইনপুট'),
                    const SizedBox(height: 8),
                    Text(
                      '"${payload.inputPreview}"',
                      style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant)
                          .copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              payload.disclaimer,
              textAlign: TextAlign.center,
              style: AppTextStyles.monoLabel(11, color: AppColors.onSurfaceVariant)
                  .copyWith(fontStyle: FontStyle.italic),
            ),
            if (payload.aiSource != null) ...[
              const SizedBox(height: 8),
              Text(
                'উৎস: ${payload.aiSource}',
                textAlign: TextAlign.center,
                style: AppTextStyles.monoLabel(10, color: AppColors.outline),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.refresh),
              label: const Text('নতুন স্ক্যান'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
