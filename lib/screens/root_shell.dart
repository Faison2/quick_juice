import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_bottom_nav.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final _dashboardKey = GlobalKey<DashboardScreenState>();

  static const _items = [
    GlassNavItem(icon: Icons.home_outlined, label: 'Home'),
    GlassNavItem(icon: Icons.receipt_long_outlined, label: 'History'),
    GlassNavItem(icon: Icons.settings_outlined, label: 'Settings'),
    GlassNavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  void _onTap(int index) {
    setState(() => _index = index);
    if (index == 0) {
      _dashboardKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(key: _dashboardKey),
      const HistoryScreen(),
      const SettingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.screenBg,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: GlassBottomNav(
        items: _items,
        currentIndex: _index,
        onTap: _onTap,
      ),
    );
  }
}
