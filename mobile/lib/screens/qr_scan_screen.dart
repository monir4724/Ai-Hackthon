import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/api/api_client.dart';
import '../core/api/api_models.dart';
import '../core/api/app_services.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/async_state.dart';
import '../widgets/screen_shell.dart';
import 'result_screen.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _permissionGranted = false;
  bool _permissionChecked = false;
  bool _permissionPermanentlyDenied = false;
  bool _processing = false;
  bool _handled = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _ensureCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ensureCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (!mounted) return;
    setState(() {
      _permissionChecked = true;
      _permissionGranted = status.isGranted;
      _permissionPermanentlyDenied = status.isPermanentlyDenied;
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue?.trim();
    if (raw == null || raw.isEmpty) return;

    setState(() {
      _processing = true;
      _handled = true;
      _statusMessage = 'বিশ্লেষণ চলছে...';
    });

    try {
      final sessionId = AppServices.session.getSessionId();
      final result = await AppServices.api.checkQr(raw, sessionId: sessionId);
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => ResultScreen(
            payload: VerdictPayload.fromQrCheck(result, payload: raw),
          ),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _handled = false;
        _statusMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processing = false;
        _handled = false;
        _statusMessage = 'বিশ্লেষণ ব্যর্থ হয়েছে। আবার স্ক্যান করুন।';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: rokkhakobochAppBar('QR স্ক্যান — আর্থিক সুরক্ষা'),
      body: !_permissionChecked
          ? const LoadingView(message: 'ক্যামেরা অনুমতি যাচাই...')
          : !_permissionGranted
              ? _permissionDeniedBody()
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                    ),
                    _viewfinderOverlay(),
                    if (_processing)
                      Container(
                        color: Colors.black54,
                        child: LoadingView(message: _statusMessage ?? 'বিশ্লেষণ চলছে...'),
                      ),
                    if (!_processing && _statusMessage != null)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 100,
                        child: Material(
                          color: AppColors.danger.withValues(alpha: 0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _statusMessage!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.siliguriBody(14, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 24,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _controller.toggleTorch(),
                            icon: const Icon(Icons.flashlight_on),
                            label: const Text('টর্চ'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.accentOn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _permissionDeniedBody() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.no_photography, size: 64, color: AppColors.danger),
          const SizedBox(height: 16),
          Text(
            'QR স্ক্যান করতে ক্যামেরার অনুমতি প্রয়োজন।',
            textAlign: TextAlign.center,
            style: AppTextStyles.tiroHeadline(20),
          ),
          const SizedBox(height: 12),
          Text(
            'অনুগ্রহ করে সেটিংস থেকে ক্যামেরা চালু করুন, অথবা নিচের বোতামে ট্যাপ করুন।',
            textAlign: TextAlign.center,
            style: AppTextStyles.siliguriBody(15, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          if (_permissionPermanentlyDenied)
            FilledButton.icon(
              onPressed: openAppSettings,
              icon: const Icon(Icons.settings),
              label: const Text('সেটিংস খুলুন'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            )
          else
            FilledButton.icon(
              onPressed: _ensureCameraPermission,
              icon: const Icon(Icons.camera_alt),
              label: const Text('আবার অনুমতি দিন'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            ),
        ],
      ),
    );
  }

  Widget _viewfinderOverlay() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.accent, width: 3),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: _corner(),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Transform.rotate(angle: 1.5708, child: _corner()),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Transform.rotate(angle: 3.14159, child: _corner()),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Transform.rotate(angle: -1.5708, child: _corner()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _corner() {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.primary, width: 4),
          left: BorderSide(color: AppColors.primary, width: 4),
        ),
      ),
    );
  }
}
