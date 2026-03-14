import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/core/puzzle/puzzle_rules.dart';

void main() {
  group('PuzzleRules', () {
    test('isSolved returns true for solved board', () {
      final board = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 0],
      ];

      expect(PuzzleRules.isSolved(board), isTrue);
    });

    test('isSolved returns false for unsolved board', () {
      final board = [
        [1, 2, 3],
        [4, 5, 6],
        [7, 0, 8],
      ];

      expect(PuzzleRules.isSolved(board), isFalse);
    });

    test('findEmpty finds zero tile', () {
      final board = [
        [1, 2, 3],
        [4, 0, 6],
        [7, 5, 8],
      ];

      final empty = PuzzleRules.findEmpty(board);
      expect(empty.row, 1);
      expect(empty.col, 1);
    });

    test('canMove returns true for adjacent tile', () {
      final board = [
        [1, 2, 3],
        [4, 0, 6],
        [7, 5, 8],
      ];

      expect(PuzzleRules.canMove(board, 1, 0), isTrue);
      expect(PuzzleRules.canMove(board, 2, 1), isTrue);
    });

    test('canMove returns false for non adjacent tile', () {
      final board = [
        [1, 2, 3],
        [4, 0, 6],
        [7, 5, 8],
      ];

      expect(PuzzleRules.canMove(board, 0, 0), isFalse);
      expect(PuzzleRules.canMove(board, 2, 2), isFalse);
    });

    test('move swaps tile with empty when valid', () {
      final board = [
        [1, 2, 3],
        [4, 0, 6],
        [7, 5, 8],
      ];

      final moved = PuzzleRules.move(board, 2, 1);

      expect(moved, [
        [1, 2, 3],
        [4, 5, 6],
        [7, 0, 8],
      ]);
    });

    test('move returns same board when invalid', () {
      final board = [
        [1, 2, 3],
        [4, 0, 6],
        [7, 5, 8],
      ];

      final moved = PuzzleRules.move(board, 0, 0);
      expect(moved, board);
    });
  });
}
