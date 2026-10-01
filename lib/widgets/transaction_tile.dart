import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_item.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem item;
  final VoidCallback onTap;

  const TransactionTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [item.logoColor, item.logoColorDark],
                  ),
                ),
                child: Icon(item.logoIcon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                    if (item.tokenLabel != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          item.tokenLabel!,
                          style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(item.amountLabel, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('dd-MM-yy').format(item.date),
                    style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
