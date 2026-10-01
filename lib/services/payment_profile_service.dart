import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_profile.dart';

class PaymentProfileService {
  static const _key = 'payment_profiles';

  Future<List<PaymentProfile>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => PaymentProfile.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(PaymentProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.add(jsonEncode(profile.toJson()));
    await prefs.setStringList(_key, raw);
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) => (jsonDecode(e) as Map<String, dynamic>)['id'] == id);
    await prefs.setStringList(_key, raw);
  }
}
