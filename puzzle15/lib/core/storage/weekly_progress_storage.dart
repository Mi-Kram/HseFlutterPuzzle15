import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class WeeklyProgressStorage {
  WeeklyProgressStorage(this._prefs);

  final SharedPreferences _prefs;

  static String _key(int year, int month, int day) =>
      'weekly_result_${year}_${month}_$day';

  Future<void> saveResult({
    required int year,
    required int month,
    required int day,
    required int moves,
    required int seconds,
  }) async {
    final oldResult = readResult(year: year, month: month, day: day);

    if (oldResult != null) {
      moves = min(moves, oldResult.moves);
      seconds = min(moves, oldResult.seconds);
    }

    await _prefs.setString(_key(year, month, day), '$moves|$seconds');
  }

  ({int moves, int seconds})? readResult({
    required int year,
    required int month,
    required int day,
  }) {
    final value = _prefs.getString(_key(year, month, day));
    if (value == null) return null;

    final parts = value.split('|');
    if (parts.length != 2) return null;

    return (moves: int.parse(parts[0]), seconds: int.parse(parts[1]));
  }
}
