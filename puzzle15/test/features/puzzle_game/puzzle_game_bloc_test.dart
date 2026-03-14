import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/features/puzzle_game/presentation/bloc/puzzle_game_bloc.dart';

void main() {
  final initialBoard = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 0, 8],
  ];

  group('PuzzleGameBloc', () {
    blocTest<PuzzleGameBloc, PuzzleGameState>(
      'PuzzleStarted initializes board',
      build: PuzzleGameBloc.new,
      act: (bloc) => bloc.add(PuzzleStarted(initialBoard, null)),
      expect: () => [
        isA<PuzzleGameState>()
            .having((s) => s.board, 'board', initialBoard)
            .having((s) => s.moves, 'moves', 0)
            .having((s) => s.seconds, 'seconds', 0)
            .having((s) => s.completed, 'completed', false),
      ],
    );

    blocTest<PuzzleGameBloc, PuzzleGameState>(
      'valid tile tap moves tile and increments moves',
      build: PuzzleGameBloc.new,
      seed: () => PuzzleGameState.initial().copyWith(
        board: initialBoard,
        initialBoard: initialBoard,
      ),
      act: (bloc) => bloc.add(PuzzleTileTapped(2, 2)),
      expect: () => [
        isA<PuzzleGameState>()
            .having((s) => s.moves, 'moves', 1)
            .having((s) => s.completed, 'completed', true),
      ],
    );

    blocTest<PuzzleGameBloc, PuzzleGameState>(
      'invalid tile tap does nothing',
      build: PuzzleGameBloc.new,
      seed: () => PuzzleGameState.initial().copyWith(
        board: initialBoard,
        initialBoard: initialBoard,
      ),
      act: (bloc) => bloc.add(PuzzleTileTapped(0, 0)),
      expect: () => [],
    );

    blocTest<PuzzleGameBloc, PuzzleGameState>(
      'tick increments seconds when not paused',
      build: PuzzleGameBloc.new,
      seed: () => PuzzleGameState.initial().copyWith(
        board: initialBoard,
        initialBoard: initialBoard,
      ),
      act: (bloc) => bloc.add(PuzzleTicked()),
      expect: () => [
        isA<PuzzleGameState>().having((s) => s.seconds, 'seconds', 1),
      ],
    );

    blocTest<PuzzleGameBloc, PuzzleGameState>(
      'tick does not increment when paused',
      build: PuzzleGameBloc.new,
      seed: () => PuzzleGameState.initial().copyWith(
        board: initialBoard,
        initialBoard: initialBoard,
        paused: true,
      ),
      act: (bloc) => bloc.add(PuzzleTicked()),
      expect: () => [],
    );

    blocTest<PuzzleGameBloc, PuzzleGameState>(
      'reset restores initial board and counters',
      build: PuzzleGameBloc.new,
      seed: () => PuzzleGameState.initial().copyWith(
        board: const [
          [1, 2, 3],
          [4, 5, 6],
          [0, 7, 8],
        ],
        initialBoard: initialBoard,
        moves: 7,
        seconds: 10,
      ),
      act: (bloc) => bloc.add(PuzzleReset()),
      expect: () => [
        isA<PuzzleGameState>()
            .having((s) => s.board, 'board', initialBoard)
            .having((s) => s.moves, 'moves', 0)
            .having((s) => s.seconds, 'seconds', 0),
      ],
    );
  });
}
