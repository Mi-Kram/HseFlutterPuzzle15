import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets('home page shows main buttons', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('Еженедельные задания'), findsOneWidget);
    expect(find.text('Новая игра'), findsOneWidget);
    expect(find.text('Турнир · скоро'), findsOneWidget);
  });
}
