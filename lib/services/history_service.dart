import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/network.dart';
import '../models/recharge_record.dart';

class HistoryService {
  static const _historyKey = 'recharge_history';
  static const _defaultNetworkKey = 'default_network';

  Future<List<RechargeRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    final records = raw
        .map((e) => RechargeRecord.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    records.sort((a, b) => b.dialedAt.compareTo(a.dialedAt));
    return records;
  }

  Future<void> add(RechargeRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey) ?? [];
    raw.add(jsonEncode(record.toJson()));
    await prefs.setStringList(_historyKey, raw);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<Network> getDefaultNetwork() async {
    final prefs = await SharedPreferences.getInstance();
    return NetworkDetails.fromStorageKey(prefs.getString(_defaultNetworkKey));
  }

  Future<void> setDefaultNetwork(Network network) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultNetworkKey, network.storageKey);
  }
}
