import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/network.dart';
import '../models/recharge_record.dart';
import '../models/transaction_item.dart';
import '../models/zesa_purchase.dart';
import '../services/history_service.dart';
import '../services/zesa_history_service.dart';
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
  final _zesaHistoryService = ZesaHistoryService();
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
    final purchases = await _zesaHistoryService.load();
    if (!mounted) return;
    setState(() {
      _items = TransactionItem.merge(recharges, purchases);
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
    if (item.source == TransactionSource.zesa) {
      _openZesaDetail(item.zesa!);
    } else {
      _openRechargeDetail(item.recharge!);
    }
  }

  void _openZesaDetail(ZesaPurchase p) {
    final rows = <DetailRow>[
      if (p.token != null) DetailRow(label: 'Zesa Token', value: p.token!),
      DetailRow(label: 'Zesa Meter Number', value: p.meterNumber),
      if (p.splitMeterToken != null) DetailRow(label: 'Split Meter Token', value: p.splitMeterToken!),
      if (p.splitMeterNumber != null) DetailRow(label: 'Split Meter Number', value: p.splitMeterNumber!),
      if (p.kwh != null) DetailRow(label: 'KwH', value: p.kwh!),
      if (p.energy != null) DetailRow(label: 'Energy', value: p.energy!),
      if (p.debt != null) DetailRow(label: 'Debt', value: p.debt!),
      if (p.rea != null) DetailRow(label: 'REA', value: p.rea!),
      if (p.vat != null) DetailRow(label: 'VAT', value: p.vat!),
      DetailRow(label: 'Total Amt', value: p.totalAmt ?? '${p.currency.label} ${p.amount}'),
      if (p.tendered != null) DetailRow(label: 'Tendered', value: p.tendered!),
      DetailRow(label: 'Date', value: DateFormat('dd/MM/yy HH:mm').format(p.purchasedAt)),
    ];

    showAppDialog(
      context: context,
      title: 'Transaction History',
      child: Column(children: rows),
      primaryLabel: 'Download Receipt',
      onPrimary: () {
        final buffer = StringBuffer('Zesa Purchase Receipt\n\n');
        buffer.writeln('Meter Number: ${p.meterNumber}');
        if (p.splitMeterNumber != null) buffer.writeln('Split Meter Number: ${p.splitMeterNumber}');
        buffer.writeln('Mobile Number: ${p.ecocashNumber}');
        buffer.writeln('Amount: ${p.currency.label} ${p.amount}');
        if (p.token != null) buffer.writeln('Token: ${p.token}');
        if (p.kwh != null) buffer.writeln('KwH: ${p.kwh}');
        if (p.energy != null) buffer.writeln('Energy: ${p.energy}');
        if (p.debt != null) buffer.writeln('Debt: ${p.debt}');
        if (p.rea != null) buffer.writeln('REA: ${p.rea}');
        if (p.vat != null) buffer.writeln('VAT: ${p.vat}');
        if (p.totalAmt != null) buffer.writeln('Total Amt: ${p.totalAmt}');
        if (p.tendered != null) buffer.writeln('Tendered: ${p.tendered}');
        buffer.writeln('Date: ${DateFormat('dd/MM/yy HH:mm').format(p.purchasedAt)}');
        SharePlus.instance.share(ShareParams(text: buffer.toString()));
      },
    );
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
