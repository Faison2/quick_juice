import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/saved_meter.dart';

class MeterService {
  static const _key = 'saved_meters';

  Future<List<SavedMeter>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => SavedMeter.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(SavedMeter meter) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(meter.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => (jsonDecode(e) as Map<String, dynamic>)['id'] == id);
    await prefs.setStringList(_key, raw);
  }
}
