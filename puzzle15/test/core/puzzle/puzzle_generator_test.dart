import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/core/puzzle/puzzle_generator.dart';
import 'package:puzzle15/core/puzzle/puzzle_rules.dart';

void main() {
  group('PuzzleGenerator', () {
    test('generate returns NxN board', () {
      final board = PuzzleGenerator.generate(4);
      expect(board.length, 4);
      expect(board.every((row) => row.length == 4), isTrue);
    });

    test('generate contains all values from 0 to N*N-1', () {
      final board = PuzzleGenerator.generate(3);
      final values = board.expand((e) => e).toList()..sort();
      expect(values, List.generate(9, (i) => i));
    });

    test('generate does not return solved board', () {
      final board = PuzzleGenerator.generate(4);
      expect(PuzzleRules.isSolved(board), isFalse);
    });
  });
}
