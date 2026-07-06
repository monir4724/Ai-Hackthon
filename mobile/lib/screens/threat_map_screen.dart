import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/api/api_client.dart';
import '../core/api/api_models.dart';
import '../core/api/app_services.dart';
import '../core/data/bangladesh_divisions.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/async_state.dart';
import 'feed_screen.dart';

class DivisionThreatSummary {
  DivisionThreatSummary({
    required this.label,
    required this.center,
    required this.count,
    required this.highRiskCount,
  });

  final String label;
  final LatLng center;
  final int count;
  final int highRiskCount;

  double get riskRatio => count == 0 ? 0 : highRiskCount / count;
}

class ThreatMapScreen extends StatefulWidget {
  const ThreatMapScreen({super.key});

  @override
  State<ThreatMapScreen> createState() => _ThreatMapScreenState();
}

class _ThreatMapScreenState extends State<ThreatMapScreen> {
  List<DivisionThreatSummary>? _summaries;
  int _unknownCount = 0;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final patterns = await AppServices.api.fetchReports();
      final grouped = <String, List<ScamPattern>>{};
      var unknown = 0;

      for (final p in patterns) {
        final label = p.locationLabel?.trim();
        final center = BangladeshDivisions.resolveCenter(label);
        if (center == null) {
          unknown++;
          continue;
        }
        grouped.putIfAbsent(label!, () => []).add(p);
      }

      final summaries = grouped.entries.map((e) {
        final high = e.value.where((p) => p.riskLevel == 'high').length;
        return DivisionThreatSummary(
          label: e.key,
          center: BangladeshDivisions.centers[e.key]!,
          count: e.value.length,
          highRiskCount: high,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _summaries = summaries;
        _unknownCount = unknown;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'মানচিত্র ডেটা লোড করা যায়নি।';
        _loading = false;
      });
    }
  }

  void _showDivisionSheet(DivisionThreatSummary summary) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(summary.label, style: AppTextStyles.tiroHeadline(22)),
            const SizedBox(height: 8),
            Text(
              'মোট রিপোর্ট: ${summary.count} · উচ্চ ঝুঁকি: ${summary.highRiskCount}',
              style: AppTextStyles.siliguriBody(15, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FeedScreen(divisionFilter: summary.label),
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('বিস্তারিত দেখুন'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const LoadingView(message: 'হুমকি মানচিত্র লোড হচ্ছে...');
    }
    if (_error != null) {
      return ErrorView(message: _error!, onRetry: _load);
    }

    final summaries = _summaries ?? [];
    final circles = summaries.map((s) {
      final ratio = s.riskRatio;
      final radius = 12000.0 + (s.count * 2500.0);
      final color = Color.lerp(AppColors.accent, AppColors.danger, ratio.clamp(0.0, 1.0))!;
      return CircleMarker(
        point: s.center,
        radius: radius,
        useRadiusInMeter: true,
        color: color.withValues(alpha: 0.35),
        borderColor: color,
        borderStrokeWidth: 2,
      );
    }).toList();

    return Stack(
      children: [
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(23.685, 90.3563),
            initialZoom: 6.5,
            interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.rokkhakoboch.rokkhakoboch',
            ),
            CircleLayer(circles: circles),
            MarkerLayer(
              markers: summaries
                  .map(
                    (s) => Marker(
                      point: s.center,
                      width: 48,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => _showDivisionSheet(s),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accent, width: 2),
                          ),
                          child: Text(
                            '${s.count}',
                            style: AppTextStyles.monoLabel(11, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        if (_unknownCount > 0)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Material(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '$_unknownCount টি রিপোর্টে বিভাগ উল্লেখ নেই (মানচিত্রে দেখানো হয়নি)',
                  style: AppTextStyles.monoLabel(11, color: AppColors.onSurfaceVariant),
                ),
              ),
            ),
          ),
        if (summaries.isEmpty)
          const Center(
            child: EmptyView(
              message:
                  'বিভাগ-ট্যাগ করা রিপোর্ট এখনো নেই — নতুন রিপোর্টে বিভাগ যোগ করলে মানচিত্রে দেখা যাবে।',
            ),
          ),
      ],
    );
  }
}
