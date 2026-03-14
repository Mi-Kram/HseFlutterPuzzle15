class PuzzleRules {
  const PuzzleRules._();

  static bool isSolved(List<List<int>> puzzle) {
    final size = puzzle.length;
    var expected = 1;
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final isLast = r == size - 1 && c == size - 1;
        if (isLast) return puzzle[r][c] == 0;
        if (puzzle[r][c] != expected) return false;
        expected++;
      }
    }
    return true;
  }

  static ({int row, int col}) findEmpty(List<List<int>> puzzle) {
    for (var r = 0; r < puzzle.length; r++) {
      for (var c = 0; c < puzzle[r].length; c++) {
        if (puzzle[r][c] == 0) return (row: r, col: c);
      }
    }
    throw StateError('Empty tile not found');
  }

  static bool canMove(List<List<int>> puzzle, int row, int col) {
    final empty = findEmpty(puzzle);
    final dr = (empty.row - row).abs();
    final dc = (empty.col - col).abs();
    return dr + dc == 1;
  }

  static List<List<int>> move(List<List<int>> puzzle, int row, int col) {
    if (!canMove(puzzle, row, col)) return puzzle;
    final empty = findEmpty(puzzle);
    final copy = puzzle.map((e) => [...e]).toList();
    copy[empty.row][empty.col] = copy[row][col];
    copy[row][col] = 0;
    return copy;
  }
}
