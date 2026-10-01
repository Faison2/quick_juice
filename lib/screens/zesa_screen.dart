import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/payment_profile.dart';
import '../models/saved_meter.dart';
import '../models/zesa_purchase.dart';
import '../services/meter_service.dart';
import '../services/payment_profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/detail_dialog.dart';
import '../widgets/glass_card.dart';
import 'zesa_guide_screen.dart';

class ZesaScreen extends StatefulWidget {
  final MeterMode initialMode;

  const ZesaScreen({super.key, required this.initialMode});

  @override
  State<ZesaScreen> createState() => _ZesaScreenState();
}

class _ZesaScreenState extends State<ZesaScreen> {
  late final MeterMode _mode = widget.initialMode;
  ZesaCurrency _currency = ZesaCurrency.usd;
  final _meterController = TextEditingController();
  final _splitMeterController = TextEditingController();
  final _ecocashController = TextEditingController();
  final _amountController = TextEditingController();
  final _meterService = MeterService();
  final _profileService = PaymentProfileService();

  @override
  void dispose() {
    _meterController.dispose();
    _splitMeterController.dispose();
    _ecocashController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    final meterOk = _meterController.text.trim().isNotEmpty &&
        (_mode == MeterMode.single || _splitMeterController.text.trim().isNotEmpty);
    return meterOk &&
        _ecocashController.text.trim().isNotEmpty &&
        _amountController.text.trim().isNotEmpty;
  }

  Future<void> _pickSavedMeter() async {
    final meters = await _meterService.load();
    if (!mounted) return;
    if (meters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved meters yet — add one from Meters.')),
      );
      return;
    }
    final chosen = await showAppDialog<SavedMeter>(
      context: context,
      title: 'Choose Meter',
      child: Column(
        children: meters
            .map(
              (m) => ProfileRow(
                brand: m.label,
                value: m.meterNumber,
                subtitle: m.isSplit ? 'Split: ${m.splitMeterNumber}' : null,
                onTap: () => Navigator.of(context).pop(m),
              ),
            )
            .toList(),
      ),
    );
    if (chosen != null) {
      setState(() {
        _meterController.text = chosen.meterNumber;
        if (chosen.isSplit && chosen.splitMeterNumber != null) {
          _splitMeterController.text = chosen.splitMeterNumber!;
        }
      });
    }
  }

  Future<void> _pickSavedProfile() async {
    final profiles = await _profileService.load();
    if (!mounted) return;
    if (profiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved payment profiles yet — add one from Payment Profiles.')),
      );
      return;
    }
    final chosen = await showAppDialog<PaymentProfile>(
      context: context,
      title: 'Choose Payment Profile',
      child: Column(
        children: profiles
            .map(
              (p) => ProfileRow(
                brand: 'EcoCash',
                value: p.ecocashNumber,
                subtitle: p.label,
                onTap: () => Navigator.of(context).pop(p),
              ),
            )
            .toList(),
      ),
      secondaryLabel: 'Enter manually',
      onSecondary: () => Navigator.of(context).pop(),
    );
    if (chosen != null) {
      setState(() => _ecocashController.text = chosen.ecocashNumber);
    }
  }

  Future<void> _proceed() async {
    if (!_canProceed) return;
    final rows = [
      DetailRow(
        label: _mode == MeterMode.split ? 'Main Meter Number' : 'Zesa meter number',
        value: _meterController.text.trim(),
      ),
      if (_mode == MeterMode.split)
        DetailRow(label: 'Split meter number', value: _splitMeterController.text.trim()),
      DetailRow(label: 'Mobile number', value: _ecocashController.text.trim()),
      DetailRow(
        label: 'Amount',
        value: '${_currency.label} ${_amountController.text.trim()}',
      ),
    ];

    final confirmed = await showAppDialog<bool>(
      context: context,
      topIcon: Icons.receipt_long,
      title: 'Confirm Details',
      child: Column(children: rows),
      primaryLabel: 'Make Payment',
      onPrimary: () => Navigator.of(context).pop(true),
    );

    if (confirmed == true && mounted) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ZesaGuideScreen(
            mode: _mode,
            meterNumber: _meterController.text.trim(),
            splitMeterNumber: _mode == MeterMode.split ? _splitMeterController.text.trim() : null,
            ecocashNumber: _ecocashController.text.trim(),
            amount: _amountController.text.trim(),
            currency: _currency,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GlassIconButton(icon: Icons.arrow_back, onTap: () => Navigator.of(context).pop()),
                  const SizedBox(width: 16),
                  const Text(
                    'Zesa',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(color: AppColors.brandGreenTint, shape: BoxShape.circle),
                  child: const Icon(Icons.receipt_long, color: AppColors.brandGreen, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardWhite,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: ZesaCurrency.values.map((c) {
                      final selected = c == _currency;
                      return GestureDetector(
                        onTap: () => setState(() => _currency = c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.brandGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            c.label,
                            style: TextStyle(
                              color: selected ? Colors.white : AppColors.inkMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              _UnderlinedField(
                label: _mode == MeterMode.split ? 'Main meter number' : 'Zesa meter number',
                controller: _meterController,
                keyboardType: TextInputType.number,
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark_outline, color: AppColors.brandGreen),
                  onPressed: _pickSavedMeter,
                ),
                onChanged: () => setState(() {}),
              ),
              if (_mode == MeterMode.split) ...[
                const SizedBox(height: 20),
                _UnderlinedField(
                  label: 'Split meter number',
                  controller: _splitMeterController,
                  keyboardType: TextInputType.number,
                  onChanged: () => setState(() {}),
                ),
              ],
              const SizedBox(height: 20),
              _UnderlinedField(
                label: 'Mobile number',
                controller: _ecocashController,
                keyboardType: TextInputType.phone,
                trailing: IconButton(
                  icon: const Icon(Icons.bookmark_outline, color: AppColors.brandGreen),
                  onPressed: _pickSavedProfile,
                ),
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 20),
              _UnderlinedField(
                label: 'Amount',
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canProceed ? _proceed : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text('Proceed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnderlinedField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? trailing;
  final VoidCallback onChanged;

  const _UnderlinedField({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.inputFormatters,
    this.trailing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.ink),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.brandGreen)),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppColors.brandGreen, width: 2)),
            ),
            onChanged: (_) => onChanged(),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
