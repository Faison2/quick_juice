import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_profile.dart';
import '../services/payment_profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class PaymentProfilesScreen extends StatefulWidget {
  const PaymentProfilesScreen({super.key});

  @override
  State<PaymentProfilesScreen> createState() => _PaymentProfilesScreenState();
}

class _PaymentProfilesScreenState extends State<PaymentProfilesScreen> {
  final _service = PaymentProfileService();
  List<PaymentProfile> _profiles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profiles = await _service.load();
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _loading = false;
    });
  }

  Future<void> _delete(String id) async {
    await _service.delete(id);
    _load();
  }

  Future<void> _addProfile() async {
    final labelController = TextEditingController();
    final numberController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Payment Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Label (e.g. My EcoCash)'),
            ),
            TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'EcoCash number'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Save')),
        ],
      ),
    );

    if (saved == true &&
        labelController.text.trim().isNotEmpty &&
        numberController.text.trim().isNotEmpty) {
      await _service.add(
        PaymentProfile(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          label: labelController.text.trim(),
          ecocashNumber: numberController.text.trim(),
        ),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backdrop),
        child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  GlassIconButton(icon: Icons.arrow_back, onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Payment Profiles',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                  GlassIconButton(icon: Icons.add, onTap: _addProfile),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : _profiles.isEmpty
                      ? const Center(
                          child: Text('No saved payment profiles yet.', style: TextStyle(color: Colors.white70)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                          itemCount: _profiles.length,
                          itemBuilder: (context, index) {
                            final p = _profiles[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GlassCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        color: AppColors.profilePurpleBg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.profilePurple),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                                          Text(
                                            'EcoCash • ${p.ecocashNumber}',
                                            style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.dangerRed),
                                      onPressed: () => _delete(p.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
