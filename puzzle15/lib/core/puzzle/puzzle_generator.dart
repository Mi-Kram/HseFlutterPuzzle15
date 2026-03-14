import 'dart:math';

class PuzzleGenerator {
  const PuzzleGenerator._();

  static List<List<int>> generate(int size) {
    final total = size * size;
    final values = List<int>.generate(total, (i) => i);
    final random = Random();

    do {
      values.shuffle(random);
    } while (!_isSolvable(values, size) || _isSolved(values));

    return List.generate(
      size,
      (r) => List.generate(size, (c) => values[r * size + c]),
    );
  }

  static bool _isSolved(List<int> values) {
    for (var i = 0; i < values.length - 1; i++) {
      if (values[i] != i + 1) return false;
    }
    return values.last == 0;
  }

  static bool _isSolvable(List<int> values, int size) {
    int inversions = 0;
    final arr = values.where((e) => e != 0).toList();
    for (var i = 0; i < arr.length; i++) {
      for (var j = i + 1; j < arr.length; j++) {
        if (arr[i] > arr[j]) inversions++;
      }
    }

    if (size.isOdd) return inversions.isEven;

    final zeroIndex = values.indexOf(0);
    final rowFromBottom = size - (zeroIndex ~/ size);
    return rowFromBottom.isEven ? inversions.isOdd : inversions.isEven;
  }
}
