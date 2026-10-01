import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'network.dart';
import 'recharge_record.dart';
import 'zesa_purchase.dart';

enum TransactionSource { airtime, zesa }

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
  final ZesaPurchase? zesa;

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
    this.zesa,
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

  factory TransactionItem.fromZesa(ZesaPurchase purchase) {
    return TransactionItem(
      source: TransactionSource.zesa,
      title: 'Zesa',
      logoIcon: Icons.bolt_outlined,
      logoColor: AppColors.brandGreen,
      logoColorDark: AppColors.brandGreenDark,
      amountLabel: '${purchase.currency.label} ${purchase.amount}',
      tokenLabel: purchase.token != null ? 'Token: ${purchase.token}' : null,
      date: purchase.purchasedAt,
      zesa: purchase,
    );
  }

  static List<TransactionItem> merge(
    List<RechargeRecord> recharges,
    List<ZesaPurchase> purchases,
  ) {
    final items = [
      ...recharges.map(TransactionItem.fromRecharge),
      ...purchases.map(TransactionItem.fromZesa),
    ];
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }
}
