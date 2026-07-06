import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/app_services.dart';
import '../core/api/api_models.dart';
import '../core/theme/app_colors.dart';
import '../widgets/async_state.dart';
import '../widgets/forensic_label.dart';
import '../widgets/paper_card.dart';
import '../widgets/screen_shell.dart';
import 'result_screen.dart';

class UrlCheckScreen extends StatefulWidget {
  const UrlCheckScreen({super.key});

  @override
  State<UrlCheckScreen> createState() => _UrlCheckScreenState();
}

class _UrlCheckScreenState extends State<UrlCheckScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final url = _controller.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'URL লিখুন');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AppServices.api.checkUrl(url);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            payload: VerdictPayload.fromUrlCheck(result, url: url),
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'URL যাচাই ব্যর্থ হয়েছে।');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rokkhakobochAppBar('লিংক নিরাপত্তা যাচাই'),
      body: _loading
          ? const LoadingView(message: 'যাচাই হচ্ছে...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ForensicLabel('মডিউল ০৩ — URL/ফিশিং লিংক গার্ড'),
                  const SizedBox(height: 20),
                  PaperCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ForensicLabel('URL'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _controller,
                          keyboardType: TextInputType.url,
                          decoration: const InputDecoration(
                            hintText: 'https://...',
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Text(_error!, style: const TextStyle(color: AppColors.danger)),
                          TextButton.icon(
                            onPressed: _submit,
                            icon: const Icon(Icons.refresh),
                            label: const Text('আবার চেষ্টা করুন'),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _submit,
                          icon: const Icon(Icons.link),
                          label: const Text('লিংক স্ক্যান করুন'),
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
