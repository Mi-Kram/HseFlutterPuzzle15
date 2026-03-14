import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/features/results/presentation/pages/result_page.dart';

void main() {
  testWidgets('result page shows stats', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ResultPage(
          args: ResultRouteArgs(moves: 42, seconds: 120, weeklyDate: null),
        ),
      ),
    );

    expect(find.text('Уровень пройден!'), findsOneWidget);
    expect(find.text('Время: 120 сек'), findsOneWidget);
    expect(find.text('Ходы: 42'), findsOneWidget);
    expect(find.text('Продолжить'), findsOneWidget);
  });
}
