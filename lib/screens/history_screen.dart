import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/network.dart';
import '../models/recharge_record.dart';
import '../models/transaction_item.dart';
import '../services/history_service.dart';
import '../widgets/detail_dialog.dart';
import '../widgets/glass_card.dart';
import '../widgets/transaction_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _historyService = HistoryService();
  List<TransactionItem> _items = [];
  bool _loading = true;
  bool _newestFirst = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final recharges = await _historyService.load();
    if (!mounted) return;
    setState(() {
      _items = TransactionItem.merge(recharges);
      if (!_newestFirst) _items = _items.reversed.toList();
      _loading = false;
    });
  }

  void _toggleSort() {
    setState(() {
      _newestFirst = !_newestFirst;
      _items = _items.reversed.toList();
    });
  }

  void _openDetail(TransactionItem item) {
    _openRechargeDetail(item.recharge!);
  }

  void _openRechargeDetail(RechargeRecord r) {
    showAppDialog(
      context: context,
      title: 'Transaction Details',
      child: Column(
        children: [
          DetailRow(label: 'Network', value: r.network.label),
          DetailRow(label: 'Voucher PIN', value: r.maskedPin),
          DetailRow(label: 'Status', value: _statusLabel(r.status)),
          DetailRow(label: 'Date', value: DateFormat('dd/MM/yy HH:mm').format(r.dialedAt)),
        ],
      ),
      primaryLabel: 'Share',
      onPrimary: () {
        SharePlus.instance.share(
          ShareParams(
            text:
                '${r.network.label} Airtime Recharge\nPIN: ${r.maskedPin}\nStatus: ${_statusLabel(r.status)}\nDate: ${DateFormat('dd/MM/yy HH:mm').format(r.dialedAt)}',
          ),
        );
      },
    );
  }

  String _statusLabel(RechargeStatus status) {
    switch (status) {
      case RechargeStatus.autoDialed:
        return 'Dialed automatically';
      case RechargeStatus.dialerOpened:
        return 'Dialer opened';
      case RechargeStatus.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                ),
                GlassIconButton(icon: Icons.tune, onTap: _toggleSort),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _items.isEmpty
                    ? const Center(
                        child: Text('No transactions yet.', style: TextStyle(color: Colors.white70)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return TransactionTile(item: item, onTap: () => _openDetail(item));
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
