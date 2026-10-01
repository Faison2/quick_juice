import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: AppColors.brandGreenTint,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: AppColors.brandGreen, size: 40),
                  ),
                  const SizedBox(height: 12),
                  const Text('Guest', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.brandGreen),
                    title: const Text('Transaction History'),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.inkMuted),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: AppColors.brandGreen),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.inkMuted),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Smat Bills v1.0.0',
                style: TextStyle(color: AppColors.inkMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
