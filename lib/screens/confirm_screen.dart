import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/network.dart';
import '../models/recharge_record.dart';
import '../services/history_service.dart';
import '../services/ussd_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/network_badge.dart';

class ConfirmScreen extends StatefulWidget {
  final Network initialNetwork;
  final String initialPin;
  final List<String> candidates;

  const ConfirmScreen({
    super.key,
    required this.initialNetwork,
    required this.initialPin,
    this.candidates = const [],
  });

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  late Network _network;
  late final TextEditingController _pinController;
  final _ussdService = UssdService();
  final _historyService = HistoryService();
  bool _dialing = false;

  @override
  void initState() {
    super.initState();
    _network = widget.initialNetwork;
    _pinController = TextEditingController(text: widget.initialPin);
    _loadDefaultNetwork();
  }

  Future<void> _loadDefaultNetwork() async {
    if (widget.initialPin.isEmpty) {
      final saved = await _historyService.getDefaultNetwork();
      if (mounted) setState(() => _network = saved);
    }
  }

  String get _pin => _pinController.text.trim();

  String get _ussdCode => _network.buildUssdCode(_pin);

  bool get _canDial => _pin.isNotEmpty && RegExp(r'^\d+$').hasMatch(_pin);

  Future<void> _recharge() async {
    if (!_canDial || _dialing) return;
    setState(() => _dialing = true);

    await _historyService.setDefaultNetwork(_network);
    final outcome = await _ussdService.dial(_ussdCode);

    final status = switch (outcome) {
      DialOutcome.autoDialed => RechargeStatus.autoDialed,
      DialOutcome.dialerOpened => RechargeStatus.dialerOpened,
      _ => RechargeStatus.failed,
    };

    await _historyService.add(
      RechargeRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        network: _network,
        pin: _pin,
        dialedAt: DateTime.now(),
        status: status,
      ),
    );

    if (!mounted) return;
    setState(() => _dialing = false);

    final message = switch (outcome) {
      DialOutcome.autoDialed => 'Dialing $_ussdCode…',
      DialOutcome.dialerOpened =>
        'Dialer opened with $_ussdCode — tap call to finish.',
      DialOutcome.unsupported =>
        'USSD auto-dial only works on Android devices.',
      DialOutcome.failed => 'Could not open the dialer. Please dial manually.',
    };

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (outcome == DialOutcome.autoDialed || outcome == DialOutcome.dialerOpened) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBg,
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GlassIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Confirm Recharge',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: Network.values.map((n) {
                    final selected = n == _network;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _network = n),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.cardWhite : AppColors.rowBg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              NetworkBadge(network: n, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                n.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? AppColors.ink
                                      : AppColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Voucher PIN',
                        style: TextStyle(
                          color: AppColors.inkMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter or edit the PIN',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (widget.candidates.length > 1) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.candidates.map((c) {
                            return ActionChip(
                              label: Text(c),
                              onPressed: () {
                                _pinController.text = c;
                                setState(() {});
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  child: Row(
                    children: [
                      const Icon(Icons.dialpad, color: AppColors.inkMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _pin.isEmpty ? '${_network.ussdPrefix}…#' : _ussdCode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canDial && !_dialing ? _recharge : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _network.color,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: _dialing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Recharge Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
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
