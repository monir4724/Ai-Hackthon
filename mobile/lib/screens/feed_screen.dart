import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/app_services.dart';
import '../core/api/api_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/util/time_ago.dart';
import '../widgets/async_state.dart';
import '../widgets/forensic_label.dart';
import '../widgets/paper_card.dart';
import '../widgets/risk_chip.dart';
import '../widgets/screen_shell.dart';
import 'report_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    this.divisionFilter,
    this.embedded = false,
  });

  final String? divisionFilter;
  final bool embedded;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<ScamPattern>? _patterns;
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
      final data = await AppServices.api.fetchReports();
      if (!mounted) return;
      setState(() {
        _patterns = data;
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
        _error = 'ফিড লোড করা যায়নি।';
        _loading = false;
      });
    }
  }

  List<ScamPattern> get _visiblePatterns {
    final all = _patterns ?? [];
    final filter = widget.divisionFilter?.trim();
    if (filter == null || filter.isEmpty) return all;
    return all.where((p) => p.locationLabel?.trim() == filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _load,
      color: AppColors.primary,
      child: _buildBody(),
    );

    if (widget.embedded) {
      return Scaffold(
        body: body,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ReportScreen()),
          ),
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.accentOn,
          child: const Icon(Icons.add_alert),
        ),
      );
    }

    return Scaffold(
      appBar: rokkhakobochAppBar(
        widget.divisionFilter == null ? 'থ্রেট ফিড' : 'ফিড — ${widget.divisionFilter}',
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ReportScreen()),
        ),
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.accentOn,
        child: const Icon(Icons.add_alert),
      ),
      body: body,
    );
  }

  Widget _buildBody() {
    if (_loading && (_patterns == null || _patterns!.isEmpty)) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120, child: LoadingView(message: 'ফিড লোড হচ্ছে...')),
        ],
      );
    }

    if (_error != null && (_patterns == null || _patterns!.isEmpty)) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120, child: ErrorView(message: _error!, onRetry: _load)),
        ],
      );
    }

    final patterns = _visiblePatterns;
    if (patterns.isEmpty) {
      final message = widget.divisionFilter == null
          ? 'কোনো প্যাটার্ন পাওয়া যায়নি।'
          : '${widget.divisionFilter} বিভাগে কোনো রিপোর্ট নেই।';
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120, child: EmptyView(message: message)),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: patterns.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final total = _patterns?.length ?? patterns.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ForensicLabel(
                  widget.divisionFilter == null
                      ? 'মডিউল ১০ — জাতীয় হুমকি বুদ্ধিমত্তা'
                      : 'বিভাগ: ${widget.divisionFilter}',
                ),
                if (total > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'এখন পর্যন্ত $total টি স্ক্যাম রিপোর্ট',
                      style: AppTextStyles.monoLabel(12, color: AppColors.primary),
                    ),
                  ),
              ],
            ),
          );
        }
        final p = patterns[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RiskChip(riskLevel: p.riskLevel),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(p.category, style: AppTextStyles.monoLabel(10, color: AppColors.primary)),
                    ),
                    const Spacer(),
                    if (p.locationLabel != null && p.locationLabel!.isNotEmpty)
                      Text(
                        p.locationLabel!,
                        style: AppTextStyles.monoLabel(10, color: AppColors.outline),
                      ),
                    if (p.isCommunityReport) ...[
                      const SizedBox(width: 8),
                      Text(
                        'সম্প্রদায়',
                        style: AppTextStyles.monoLabel(10, color: AppColors.outline),
                      ),
                    ],
                  ],
                ),
                if (p.createdAt.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(timeAgoBn(p.createdAt), style: AppTextStyles.monoLabel(10, color: AppColors.outline)),
                ],
                const SizedBox(height: 8),
                Text(p.label.isNotEmpty ? p.label : p.category, style: AppTextStyles.tiroHeadline(16)),
                const SizedBox(height: 6),
                Text(
                  p.textBn,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.siliguriBody(14, color: AppColors.onSurfaceVariant),
                ),
                if (p.redFlagsBn != null && p.redFlagsBn!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'লাল পতাকা: ${p.redFlagsBn}',
                    style: AppTextStyles.monoLabel(11),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
