import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'feed_screen.dart';
import 'threat_map_screen.dart';

class ThreatIntelHubScreen extends StatelessWidget {
  const ThreatIntelHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('জাতীয় হুমকি বুদ্ধিমত্তা'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.outline,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(text: 'ফিড'),
              Tab(text: 'হুমকি মানচিত্র'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            FeedScreen(embedded: true),
            ThreatMapScreen(),
          ],
        ),
      ),
    );
  }
}
