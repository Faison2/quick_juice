import 'package:flutter/material.dart';
import 'network.dart';
import 'recharge_record.dart';

enum TransactionSource { airtime }

class TransactionItem {
  final TransactionSource source;
  final String title;
  final IconData logoIcon;
  final Color logoColor;
  final Color logoColorDark;
  final String amountLabel;
  final String? tokenLabel;
  final DateTime date;
  final RechargeRecord? recharge;

  TransactionItem({
    required this.source,
    required this.title,
    required this.logoIcon,
    required this.logoColor,
    required this.logoColorDark,
    required this.amountLabel,
    this.tokenLabel,
    required this.date,
    this.recharge,
  });

  factory TransactionItem.fromRecharge(RechargeRecord record) {
    return TransactionItem(
      source: TransactionSource.airtime,
      title: '${record.network.label} Airtime',
      logoIcon: record.network.icon,
      logoColor: record.network.color,
      logoColorDark: record.network.colorDark,
      amountLabel: '—',
      tokenLabel: 'PIN: ${record.maskedPin}',
      date: record.dialedAt,
      recharge: record,
    );
  }

  static List<TransactionItem> merge(List<RechargeRecord> recharges) {
    final items = recharges.map(TransactionItem.fromRecharge).toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }
}
