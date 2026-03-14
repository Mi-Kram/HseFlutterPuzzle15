import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/features/new_game/presentation/pages/new_game_page.dart';

void main() {
  testWidgets('new game page shows sizes from 3x3 to 9x9', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NewGamePage()));

    expect(find.text('3 x 3'), findsOneWidget);
    expect(find.text('9 x 9'), findsOneWidget);
  });
}
