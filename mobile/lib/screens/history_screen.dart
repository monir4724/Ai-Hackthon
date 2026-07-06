import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/api/app_services.dart';
import '../core/api/api_models.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/async_state.dart';
import '../widgets/forensic_label.dart';
import '../widgets/risk_chip.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanHistoryItem>? _items;
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
      final sessionId = AppServices.session.getSessionId();
      final data = await AppServices.api.fetchHistory(sessionId);
      if (!mounted) return;
      setState(() {
        _items = data;
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
        _error = 'ইতিহাস লোড করা যায়নি।';
        _loading = false;
      });
    }
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'আজ';
    if (d == yesterday) return 'গতকাল';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সাম্প্রতিক স্ক্যানসমূহ'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.outlineVariant),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 120, child: LoadingView())],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 120, child: ErrorView(message: _error!, onRetry: _load)),
        ],
      );
    }

    final items = _items ?? [];
    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120, child: EmptyView(message: 'এখনো কোনো স্ক্যান নেই।')),
        ],
      );
    }

    final children = <Widget>[
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: ForensicLabel('Scanned Evidence Log'),
      ),
    ];

    String? currentLabel;
    for (final item in items) {
      final dt = DateTime.tryParse(item.createdAt)?.toLocal();
      final label = dt != null ? _dateLabel(dt) : 'অজানা';
      if (label != currentLabel) {
        currentLabel = label;
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(label, style: AppTextStyles.monoLabel(12, color: AppColors.primary)),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),
        );
      }

      final timeStr = dt != null
          ? '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
          : '';

      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                RiskChip(riskLevel: item.riskLevel),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.inputText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.siliguriBody(14),
                  ),
                ),
                const SizedBox(width: 8),
                Text(timeStr, style: AppTextStyles.monoLabel(10)),
              ],
            ),
          ),
        ),
      );
    }

    children.add(const SizedBox(height: 24));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: children,
    );
  }
}
