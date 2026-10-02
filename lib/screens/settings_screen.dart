import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/network.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _historyService = HistoryService();
  Network _defaultNetwork = Network.econet;
  PermissionStatus? _cameraStatus;
  PermissionStatus? _phoneStatus;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final network = await _historyService.getDefaultNetwork();
    final camera = await Permission.camera.status;
    final phone = await Permission.phone.status;
    if (!mounted) return;
    setState(() {
      _defaultNetwork = network;
      _cameraStatus = camera;
      _phoneStatus = phone;
    });
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This removes all saved recharge records from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _historyService.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared.')),
        );
      }
    }
  }

  String _permissionLabel(PermissionStatus? status) {
    if (status == null) return 'Checking…';
    return status.isGranted ? 'Granted' : 'Not granted';
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
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Default network',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: Network.values.map((n) {
                      final selected = n == _defaultNetwork;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            await _historyService.setDefaultNetwork(n);
                            setState(() => _defaultNetwork = n);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: selected ? n.color.withValues(alpha: 0.15) : AppColors.rowBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected ? n.color : Colors.transparent,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                n.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selected ? n.colorDark : AppColors.inkMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permissions',
                    style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 12),
                  _PermissionRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    status: _permissionLabel(_cameraStatus),
                    onTap: () async {
                      await openAppSettings();
                    },
                  ),
                  const Divider(height: 24),
                  _PermissionRow(
                    icon: Icons.call_outlined,
                    label: 'Phone (auto-dial)',
                    status: _permissionLabel(_phoneStatus),
                    onTap: () async {
                      await openAppSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              color: Colors.white,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_outline, color: AppColors.warning),
                title: const Text('Clear history', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: _clearHistory,
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              color: Colors.white,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                  SizedBox(height: 8),
                  Text(
                    'JuiceUp scans a prepaid voucher and dials the Econet (*121*PIN#), NetOne (*133*PIN#), or Telecel (*123*PIN#) recharge code for you. Android only — auto-dial requires the Phone permission.',
                    style: TextStyle(color: AppColors.inkMuted, fontSize: 13, height: 1.4),
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

class _PermissionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String status;
  final VoidCallback onTap;

  const _PermissionRow({
    required this.icon,
    required this.label,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.inkMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Text(status, style: const TextStyle(color: AppColors.inkMuted, fontSize: 13)),
        TextButton(onPressed: onTap, child: const Text('Open Settings')),
      ],
    );
  }
}
