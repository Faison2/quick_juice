import 'package:flutter/material.dart';
import '../models/zesa_purchase.dart';
import '../services/zesa_history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

class ZesaReceiptScreen extends StatefulWidget {
  final MeterMode mode;
  final String meterNumber;
  final String? splitMeterNumber;
  final String ecocashNumber;
  final String amount;
  final ZesaCurrency currency;

  const ZesaReceiptScreen({
    super.key,
    required this.mode,
    required this.meterNumber,
    this.splitMeterNumber,
    required this.ecocashNumber,
    required this.amount,
    required this.currency,
  });

  @override
  State<ZesaReceiptScreen> createState() => _ZesaReceiptScreenState();
}

class _ZesaReceiptScreenState extends State<ZesaReceiptScreen> {
  final _historyService = ZesaHistoryService();
  final _tokenController = TextEditingController();
  final _splitTokenController = TextEditingController();
  final _kwhController = TextEditingController();
  final _energyController = TextEditingController();
  final _debtController = TextEditingController();
  final _reaController = TextEditingController();
  final _vatController = TextEditingController();
  final _totalController = TextEditingController();
  final _tenderedController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _tokenController.dispose();
    _splitTokenController.dispose();
    _kwhController.dispose();
    _energyController.dispose();
    _debtController.dispose();
    _reaController.dispose();
    _vatController.dispose();
    _totalController.dispose();
    _tenderedController.dispose();
    super.dispose();
  }

  String? _val(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    setState(() => _saving = true);
    await _historyService.add(
      ZesaPurchase(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        mode: widget.mode,
        meterNumber: widget.meterNumber,
        splitMeterNumber: widget.splitMeterNumber,
        ecocashNumber: widget.ecocashNumber,
        amount: widget.amount,
        currency: widget.currency,
        purchasedAt: DateTime.now(),
        token: _val(_tokenController),
        splitMeterToken: _val(_splitTokenController),
        kwh: _val(_kwhController),
        energy: _val(_energyController),
        debt: _val(_debtController),
        rea: _val(_reaController),
        vat: _val(_vatController),
        totalAmt: _val(_totalController),
        tendered: _val(_tenderedController),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to your Zesa purchase history.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backdrop),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add receipt details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Optional — copy these from the EcoCash SMS confirmation to keep a full record. You can skip this.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 20),
              GlassCard(
                child: Column(
                  children: [
                    _ReceiptField(label: 'Zesa Token', controller: _tokenController),
                    if (widget.mode == MeterMode.split) ...[
                      const SizedBox(height: 14),
                      _ReceiptField(label: 'Split Meter Token', controller: _splitTokenController),
                    ],
                    const SizedBox(height: 14),
                    _ReceiptField(label: 'KwH', controller: _kwhController),
                    const SizedBox(height: 14),
                    _ReceiptField(label: 'Energy', controller: _energyController),
                    const SizedBox(height: 14),
                    _ReceiptField(label: 'Debt', controller: _debtController),
                    const SizedBox(height: 14),
                    _ReceiptField(label: 'REA', controller: _reaController),
                    const SizedBox(height: 14),
                    _ReceiptField(label: 'VAT', controller: _vatController),
                    const SizedBox(height: 14),
                    _ReceiptField(label: 'Total Amt', controller: _totalController),
                    const SizedBox(height: 14),
                    _ReceiptField(label: 'Tendered', controller: _tenderedController),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navyMid,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: _saving ? null : _save,
                  child: const Text('Skip', style: TextStyle(color: Colors.white70)),
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _ReceiptField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.rowBg)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.navyMid, width: 2)),
      ),
    );
  }
}
