import 'package:flutter/material.dart';

import 'core/api/api_models.dart';
import 'core/api/app_services.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'screens/feed_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/modules_screen.dart';
import 'screens/result_screen.dart';
import 'screens/scan_screen.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppServices.init();
  NotificationService.setVerdictNavigationHandler(_openVerdictFromNotification);
  runApp(const RokkhakobochApp());
}

void _openVerdictFromNotification(VerdictPayload payload) {
  navigatorKey.currentState?.push(
    MaterialPageRoute<void>(builder: (_) => ResultScreen(payload: payload)),
  );
}

class RokkhakobochApp extends StatelessWidget {
  const RokkhakobochApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'রক্ষাকবচ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _tabs = [
    _NavTab(label: 'হোম', icon: Icons.home_outlined, activeIcon: Icons.home),
    _NavTab(label: 'স্ক্যান', icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check),
    _NavTab(label: 'ফিড', icon: Icons.rss_feed_outlined, activeIcon: Icons.rss_feed),
    _NavTab(label: 'মডিউল', icon: Icons.shield_outlined, activeIcon: Icons.shield),
    _NavTab(label: 'ইতিহাস', icon: Icons.history_outlined, activeIcon: Icons.history),
  ];

  final _screens = const [
    HomeScreen(),
    ScanScreen(),
    FeedScreen(),
    ModulesScreen(),
    HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.activeIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
}
