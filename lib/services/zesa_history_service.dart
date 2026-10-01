import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zesa_purchase.dart';

class ZesaHistoryService {
  static const _key = 'zesa_history';

  Future<List<ZesaPurchase>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final records = raw
        .map((e) => ZesaPurchase.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    records.sort((a, b) => b.purchasedAt.compareTo(a.purchasedAt));
    return records;
  }

  Future<void> add(ZesaPurchase purchase) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(purchase.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
