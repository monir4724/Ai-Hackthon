import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/app_services.dart';
import '../core/api/api_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/async_state.dart';
import '../widgets/forensic_label.dart';
import '../widgets/paper_card.dart';
import '../widgets/screen_shell.dart';
import 'result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _controller = TextEditingController();
  String _module = 'sms';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.length < 5) {
      setState(() => _error = 'কমপক্ষে ৫ অক্ষর লিখুন');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final sessionId = AppServices.session.getSessionId();
      final result = await AppServices.api.analyzeText(
        text: text,
        module: _module,
        sessionId: sessionId,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            payload: VerdictPayload.fromAnalysis(result, inputText: text),
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'বিশ্লেষণ ব্যর্থ হয়েছে। আবার চেষ্টা করুন।');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCall = _module == 'call_transcript';

    return Scaffold(
      appBar: rokkhakobochAppBar('সন্দেহজন্য মেসেজ স্ক্যান'),
      body: _loading
          ? const LoadingView(message: 'বিশ্লেষণ চলছে...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ForensicLabel(
                    isCall ? 'মডিউল ০২ — কল ট্রান্সক্রিপ্ট' : 'মডিউল ০১ — এমএফএস মেসেজ সেন্টিনেল',
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'sms', label: Text('মেসেজ')),
                      ButtonSegment(value: 'call_transcript', label: Text('কল ট্রান্সক্রিপ্ট')),
                    ],
                    selected: {_module},
                    onSelectionChanged: (s) => setState(() => _module = s.first),
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return Colors.white;
                        return AppColors.primary;
                      }),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return AppColors.primary;
                        return AppColors.surfaceContainerLow;
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PaperCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ForensicLabel('মেসেজ টেক্সট'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: isCall
                                ? 'কলার কী বলেছিল তা এখানে লিখুন...'
                                : 'সন্দেহজনক মেসেজটি এখানে কপি করুন...',
                            border: const UnderlineInputBorder(),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _error!,
                            style: AppTextStyles.siliguriBody(14, color: AppColors.danger),
                          ),
                          TextButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.refresh),
                            label: const Text('আবার চেষ্টা করুন'),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.fact_check),
                          label: const Text('ঝুঁকি যাচাই করুন'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            foregroundColor: AppColors.accentOn,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
