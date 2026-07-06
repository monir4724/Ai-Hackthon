import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../core/media/ela_analyzer.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/forensic_label.dart';
import '../widgets/paper_card.dart';
import '../widgets/screen_shell.dart';

class DeepfakeCheckScreen extends StatefulWidget {
  const DeepfakeCheckScreen({super.key});

  @override
  State<DeepfakeCheckScreen> createState() => _DeepfakeCheckScreenState();
}

class _DeepfakeCheckScreenState extends State<DeepfakeCheckScreen> {
  final _picker = ImagePicker();
  bool _processing = false;
  String? _error;
  Uint8List? _originalBytes;
  Uint8List? _heatmapBytes;
  ElaResult? _result;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _processing = true;
      _error = null;
      _originalBytes = null;
      _heatmapBytes = null;
      _result = null;
    });

    try {
      final file = await _picker.pickImage(source: source, imageQuality: 95);
      if (file == null) {
        setState(() => _processing = false);
        return;
      }

      final bytes = await file.readAsBytes();
      final analysis = await ElaAnalyzer.analyze(bytes);
      if (!mounted) return;

      if (analysis == null) {
        setState(() {
          _processing = false;
          _error = 'ছবি প্রক্রিয়া করা যায়নি।';
        });
        return;
      }

      setState(() {
        _result = analysis;
        _originalBytes = Uint8List.fromList(img.encodePng(analysis.original));
        _heatmapBytes = Uint8List.fromList(img.encodePng(analysis.heatmap));
        _processing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _error = 'ছবি বিশ্লেষণ ব্যর্থ হয়েছে।';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rokkhakobochAppBar('পরীক্ষামূলক মিডিয়া বিশ্লেষণ'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PaperCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.science_outlined, color: AppColors.accentOn),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'এটি একটি পরীক্ষামূলক (experimental) টুল — এটি নিশ্চিতভাবে ডিপফেক শনাক্ত করতে পারে না, '
                      'শুধু সম্পাদনার সম্ভাব্য চিহ্ন দেখায়।',
                      style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const ForensicLabel('মডিউল ০৬ — ELA হিউরিস্টিক'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _processing ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('গ্যালারি'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _processing ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('ক্যামেরা'),
                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ),
              ],
            ),
            if (_processing) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              const SizedBox(height: 8),
              Text(
                'ELA বিশ্লেষণ চলছে...',
                textAlign: TextAlign.center,
                style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            if (_result != null && _originalBytes != null && _heatmapBytes != null) ...[
              const SizedBox(height: 20),
              Text(_result!.verdictBn, style: AppTextStyles.tiroHeadline(18)),
              const SizedBox(height: 8),
              Text(
                _result!.detailBn,
                style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _imageCard('মূল ছবি', _originalBytes!)),
                  const SizedBox(width: 12),
                  Expanded(child: _imageCard('ELA হিটম্যাপ', _heatmapBytes!)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'সিগন্যাল স্কোর: ${_result!.signalScore.toStringAsFixed(1)} (শুধুমাত্র ইঙ্গিত)',
                style: AppTextStyles.monoLabel(11, color: AppColors.outline),
              ),
              const SizedBox(height: 12),
              Text(
                'এই ফলাফল প্রমাণ নয়, শুধুমাত্র একটি ইঙ্গিত',
                textAlign: TextAlign.center,
                style: AppTextStyles.monoLabel(11, color: AppColors.onSurfaceVariant)
                    .copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _imageCard(String label, Uint8List bytes) {
    return PaperCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: AppTextStyles.monoLabel(11)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.memory(bytes, fit: BoxFit.cover),
          ),
        ],
      ),
    );
  }
}
