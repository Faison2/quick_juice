import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/network.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/action_sheets.dart';
import '../widgets/glass_card.dart';
import '../widgets/network_badge.dart';
import 'confirm_screen.dart';
import 'scan_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final _historyService = HistoryService();
  int _monthCount = 0;
  Network? _topNetwork;
  List<int> _last7 = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final records = await _historyService.load();
    if (!mounted) return;
    final now = DateTime.now();
    final monthCount = records
        .where((r) => r.dialedAt.year == now.year && r.dialedAt.month == now.month)
        .length;

    Network? topNetwork;
    if (records.isNotEmpty) {
      final counts = <Network, int>{};
      for (final r in records) {
        counts[r.network] = (counts[r.network] ?? 0) + 1;
      }
      topNetwork = counts.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    }

    final last7 = List<int>.filled(7, 0);
    for (var i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      last7[i] = records
          .where((r) =>
              r.dialedAt.year == day.year &&
              r.dialedAt.month == day.month &&
              r.dialedAt.day == day.day)
          .length;
    }

    setState(() {
      _monthCount = monthCount;
      _topNetwork = topNetwork;
      _last7 = last7;
    });
  }

  Future<void> refresh() => _loadStats();

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
                  'JuiceUp',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const GlassIconButton(icon: Icons.person_outline),
              ],
            ),
            const SizedBox(height: 20),
            _MonthSummaryCard(
              monthCount: _monthCount,
              topNetwork: _topNetwork,
              last7: _last7,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 170,
              child: _HeroCard(
                title: 'Scan Voucher',
                icon: Icons.document_scanner_outlined,
                color: AppColors.blueMid,
                colorDark: AppColors.navyMid,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Airtime and bundles',
              style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(12),
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
    this.color = AppColors.navyMid,
    this.colorDark = AppColors.navyDeep,
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
          color: AppColors.rowBg,
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

class _MonthSummaryCard extends StatelessWidget {
  final int monthCount;
  final Network? topNetwork;
  final List<int> last7;

  const _MonthSummaryCard({
    required this.monthCount,
    required this.topNetwork,
    required this.last7,
  });

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final maxCount = last7.fold<int>(1, (m, c) => c > m ? c : m);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'THIS MONTH',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.glow, AppColors.glow.withValues(alpha: 0.4)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glow.withValues(alpha: 0.5),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$monthCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'recharges',
                        style: TextStyle(color: Colors.white60, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.18)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Top network',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        if (topNetwork != null)
                          Row(
                            children: [
                              NetworkBadge(network: topNetwork!, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                topNetwork!.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        else
                          const Text(
                            'No activity yet',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 36,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final isToday = i == 6;
                    final count = last7[i];
                    final height = 6.0 + (count / maxCount) * 30.0;
                    final day = now.subtract(Duration(days: 6 - i));
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: height,
                              decoration: BoxDecoration(
                                color: AppColors.glow.withValues(alpha: isToday ? 0.95 : 0.4),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _dayLetters[day.weekday - 1],
                              style: TextStyle(
                                color: isToday ? Colors.white : Colors.white38,
                                fontSize: 10,
                                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
