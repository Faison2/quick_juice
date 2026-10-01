import 'package:flutter/material.dart';
import '../models/network.dart';
import '../models/zesa_purchase.dart';
import '../theme/app_theme.dart';
import '../widgets/action_sheets.dart';
import '../widgets/glass_card.dart';
import '../widgets/network_badge.dart';
import 'confirm_screen.dart';
import 'meters_screen.dart';
import 'payment_profiles_screen.dart';
import 'scan_screen.dart';
import 'zesa_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {}

  Future<void> _openZesa({MeterMode? mode}) async {
    final chosenMode = mode ?? await showChooseZesaOptionDialog(context);
    if (chosenMode == null || !mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ZesaScreen(initialMode: chosenMode)),
    );
  }

  Future<void> _openNetwork(Network network) async {
    final choice = await showScanOrManualDialog(context, network.label);
    if (choice == null || !mounted) return;
    if (choice == PinEntryMethod.scan) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ScanScreen(network: network)),
      );
    } else {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConfirmScreen(initialNetwork: network, initialPin: ''),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Smatbills',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreenTint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.brandGreen),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 170,
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _HeroCard(
                    title: 'Buy Zesa',
                    icon: Icons.bolt,
                    onTap: () => _openZesa(),
                  ),
                  _HeroCard(
                    title: 'Scan Voucher',
                    icon: Icons.document_scanner_outlined,
                    color: AppColors.netone,
                    colorDark: AppColors.netoneDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ScanScreen()),
                    ),
                  ),
                  _HeroCard(
                    title: 'Zesa & Split Meter',
                    icon: Icons.bolt,
                    color: AppColors.brandGreenDark,
                    colorDark: AppColors.brandGreen,
                    onTap: () => _openZesa(mode: MeterMode.split),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.brandGreen : AppColors.inkMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text(
              'Airtime and bundles',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandGreenTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: Network.values.map((n) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _NetworkTile(network: n, onTap: () => _openNetwork(n)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Profiles',
              style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 15),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _ProfileShortcut(
                      icon: Icons.speed_outlined,
                      label: 'Meters',
                      iconColor: AppColors.meterOrange,
                      iconBg: AppColors.meterOrangeBg,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MetersScreen()),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _ProfileShortcut(
                      icon: Icons.person_outline,
                      label: 'Payment Profiles',
                      iconColor: AppColors.profilePurple,
                      iconBg: AppColors.profilePurpleBg,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PaymentProfilesScreen()),
                      ),
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

class _HeroCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color colorDark;
  final VoidCallback onTap;

  const _HeroCard({
    required this.title,
    required this.icon,
    this.color = AppColors.brandGreen,
    this.colorDark = AppColors.brandGreenDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, colorDark],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(icon, color: color),
                  ),
                  Icon(Icons.lightbulb_outline, color: Colors.white.withValues(alpha: 0.6)),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkTile extends StatelessWidget {
  final Network network;
  final VoidCallback onTap;

  const _NetworkTile({required this.network, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            NetworkBadge(network: network, size: 32),
            const SizedBox(height: 8),
            Text(
              network.label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color iconBg;
  final VoidCallback onTap;

  const _ProfileShortcut({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }
}
