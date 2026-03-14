import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzle15/core/storage/weekly_progress_storage.dart';

void main() {
  late SharedPreferences prefs;
  late WeeklyProgressStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storage = WeeklyProgressStorage(prefs);
  });

  test('saveResult and readResult work', () async {
    await storage.saveResult(
      year: 2025,
      month: 3,
      day: 10,
      moves: 50,
      seconds: 120,
    );

    final result = storage.readResult(year: 2025, month: 3, day: 10);

    expect(result, isNotNull);
    expect(result!.moves, 50);
    expect(result.seconds, 120);
  });
}
