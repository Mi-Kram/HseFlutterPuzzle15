import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  AppPrefs(this.prefs);

  final SharedPreferences prefs;

  Future<void> setBool(String key, bool value) => prefs.setBool(key, value);
  bool getBool(String key, {bool fallback = false}) =>
      prefs.getBool(key) ?? fallback;

  Future<void> setString(String key, String value) =>
      prefs.setString(key, value);
  String? getString(String key) => prefs.getString(key);

  Future<void> setStringList(String key, List<String> value) =>
      prefs.setStringList(key, value);
  List<String> getStringList(String key) =>
      prefs.getStringList(key) ?? <String>[];

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      prefs.setString(key, jsonEncode(value));

  Map<String, dynamic>? getJson(String key) {
    final raw = prefs.getString(key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
