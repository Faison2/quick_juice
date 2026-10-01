import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/zesa_purchase.dart';
import '../services/ussd_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import 'zesa_receipt_screen.dart';

class _GuideStep {
  final String instruction;
  final String? copyValue;
  final String? copyLabel;

  const _GuideStep(this.instruction, {this.copyValue, this.copyLabel});
}

class ZesaGuideScreen extends StatefulWidget {
  final MeterMode mode;
  final String meterNumber;
  final String? splitMeterNumber;
  final String ecocashNumber;
  final String amount;
  final ZesaCurrency currency;

  const ZesaGuideScreen({
    super.key,
    required this.mode,
    required this.meterNumber,
    this.splitMeterNumber,
    required this.ecocashNumber,
    required this.amount,
    this.currency = ZesaCurrency.usd,
  });

  @override
  State<ZesaGuideScreen> createState() => _ZesaGuideScreenState();
}

class _ZesaGuideScreenState extends State<ZesaGuideScreen> {
  final _ussdService = UssdService();
  bool _dialed = false;
  bool _showAltPath = false;

  String get _dialMeter =>
      widget.mode == MeterMode.split && widget.splitMeterNumber != null
          ? widget.splitMeterNumber!
          : widget.meterNumber;

  List<_GuideStep> get _primarySteps => [
    const _GuideStep('Tap "Dial *151#" below to open the EcoCash menu.'),
    const _GuideStep('Reply 2 for "Make Payment".'),
    const _GuideStep('Reply 5 for "Pay ZESA".'),
    const _GuideStep('Reply 1 for "Buy Token".'),
    _GuideStep('Paste the amount when prompted.', copyValue: widget.amount, copyLabel: 'Amount'),
    _GuideStep('Paste the meter number when prompted.', copyValue: _dialMeter, copyLabel: 'Meter Number'),
    const _GuideStep('Reply 1 to confirm, then enter your EcoCash PIN.'),
  ];

  List<_GuideStep> get _altSteps => [
    const _GuideStep('Tap "Dial *151#" below to open the EcoCash menu.'),
    const _GuideStep('Reply 2 for "Make Payment".'),
    const _GuideStep('Reply 1 for "Pay Bill" → "Pay to Biller Code".'),
    const _GuideStep('Enter Biller Code 04336 (ZESA Prepaid).'),
    _GuideStep('Paste the meter number when prompted.', copyValue: _dialMeter, copyLabel: 'Meter Number'),
    _GuideStep('Paste the amount when prompted.', copyValue: widget.amount, copyLabel: 'Amount'),
    const _GuideStep('Confirm, then enter your EcoCash PIN.'),
  ];

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copied — paste it into the EcoCash prompt.')),
    );
  }

  Future<void> _dial() async {
    final outcome = await _ussdService.dial('*151#');
    setState(() => _dialed = true);
    if (!mounted) return;
    final message = switch (outcome) {
      DialOutcome.autoDialed || DialOutcome.dialerOpened =>
        'EcoCash menu opening — follow the steps below.',
      DialOutcome.unsupported => 'USSD dialing only works on Android devices.',
      DialOutcome.failed => 'Could not open the dialer. Dial *151# manually.',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _continueToReceipt() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ZesaReceiptScreen(
          mode: widget.mode,
          meterNumber: widget.meterNumber,
          splitMeterNumber: widget.splitMeterNumber,
          ecocashNumber: widget.ecocashNumber,
          amount: widget.amount,
          currency: widget.currency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = _showAltPath ? _altSteps : _primarySteps;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backdrop),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    GlassIconButton(icon: Icons.arrow_back, onTap: () => Navigator.of(context).pop()),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Follow these steps',
                        style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < steps.length; i++) ...[
                              _StepRow(
                                number: i + 1,
                                step: steps[i],
                                onCopy: steps[i].copyValue == null
                                    ? null
                                    : () => _copy(steps[i].copyValue!, steps[i].copyLabel!),
                              ),
                              if (i != steps.length - 1) const Divider(height: 20),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(() => _showAltPath = !_showAltPath),
                        child: Text(
                          _showAltPath
                              ? 'Use "Pay ZESA" option instead'
                              : 'Don\'t see "Pay ZESA"? Try Biller Code instead',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _dial,
                          icon: const Icon(Icons.call, color: Colors.white),
                          label: const Text('Dial *151#', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.white54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _dialed ? _continueToReceipt : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.navyMid,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                          ),
                          child: const Text(
                            'I completed the purchase',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      if (!_dialed) ...[
                        const SizedBox(height: 8),
                        const Text(
                          'Dial *151# first, then come back here once EcoCash confirms your token.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final _GuideStep step;
  final VoidCallback? onCopy;

  const _StepRow({required this.number, required this.step, this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.navyMid, shape: BoxShape.circle),
          child: Text(
            '$number',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(step.instruction, style: const TextStyle(color: AppColors.ink, fontSize: 14)),
        ),
        if (onCopy != null)
          TextButton.icon(
            onPressed: onCopy,
            icon: const Icon(Icons.copy, size: 16),
            label: Text(step.copyValue!),
          ),
      ],
    );
  }
}
