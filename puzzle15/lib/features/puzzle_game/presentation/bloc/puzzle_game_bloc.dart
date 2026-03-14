import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puzzle15/core/puzzle/puzzle_rules.dart';

sealed class PuzzleGameEvent {}

class PuzzleStarted extends PuzzleGameEvent {
  PuzzleStarted(this.puzzle, this.imageData);
  final List<List<int>> puzzle;
  final String? imageData;
}

class PuzzleTileTapped extends PuzzleGameEvent {
  PuzzleTileTapped(this.row, this.col);
  final int row;
  final int col;
}

class PuzzleTicked extends PuzzleGameEvent {}

class PuzzleReset extends PuzzleGameEvent {}

class PuzzlePaused extends PuzzleGameEvent {}

class PuzzleResumed extends PuzzleGameEvent {}

class PuzzleArrowMove extends PuzzleGameEvent {
  PuzzleArrowMove(this.direction);
  final ArrowDirection direction;
}

class PuzzleImageChanged extends PuzzleGameEvent {
  PuzzleImageChanged(this.imageData);
  final String? imageData;
}

enum ArrowDirection { up, down, left, right }

class PuzzleGameState {
  const PuzzleGameState({
    required this.board,
    required this.initialBoard,
    required this.moves,
    required this.seconds,
    required this.paused,
    required this.completed,
    required this.imageData,
  });

  final List<List<int>> board;
  final List<List<int>> initialBoard;
  final int moves;
  final int seconds;
  final bool paused;
  final bool completed;
  final String? imageData;

  factory PuzzleGameState.initial() => const PuzzleGameState(
    board: [],
    initialBoard: [],
    moves: 0,
    seconds: 0,
    paused: false,
    completed: false,
    imageData: null,
  );

  PuzzleGameState copyWith({
    List<List<int>>? board,
    List<List<int>>? initialBoard,
    int? moves,
    int? seconds,
    bool? paused,
    bool? completed,
    String? imageData,
    bool? setNullImageData,
  }) {
    return PuzzleGameState(
      board: board ?? this.board,
      initialBoard: initialBoard ?? this.initialBoard,
      moves: moves ?? this.moves,
      seconds: seconds ?? this.seconds,
      paused: paused ?? this.paused,
      completed: completed ?? this.completed,
      imageData: setNullImageData == true
          ? null
          : (imageData ?? this.imageData),
    );
  }
}

class PuzzleGameBloc extends Bloc<PuzzleGameEvent, PuzzleGameState> {
  PuzzleGameBloc() : super(PuzzleGameState.initial()) {
    on<PuzzleStarted>(_onStarted);
    on<PuzzleTileTapped>(_onTapped);
    on<PuzzleTicked>(_onTicked);
    on<PuzzleReset>(_onReset);
    on<PuzzlePaused>((event, emit) => emit(state.copyWith(paused: true)));
    on<PuzzleResumed>((event, emit) => emit(state.copyWith(paused: false)));
    on<PuzzleImageChanged>(
      (event, emit) => emit(
        state.copyWith(
          setNullImageData: event.imageData == null,
          imageData: event.imageData,
        ),
      ),
    );
    on<PuzzleArrowMove>(_onArrowMove);
  }

  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(PuzzleTicked()),
    );
  }

  void _onStarted(PuzzleStarted event, Emitter<PuzzleGameState> emit) {
    emit(
      state.copyWith(
        board: event.puzzle.map((e) => [...e]).toList(),
        initialBoard: event.puzzle.map((e) => [...e]).toList(),
        moves: 0,
        seconds: 0,
        paused: false,
        completed: false,
        imageData: event.imageData,
      ),
    );
    _startTimer();
  }

  void _onTicked(PuzzleTicked event, Emitter<PuzzleGameState> emit) {
    if (state.paused || state.completed) return;
    emit(state.copyWith(seconds: state.seconds + 1));
  }

  void _onTapped(PuzzleTileTapped event, Emitter<PuzzleGameState> emit) {
    if (state.completed || state.paused) return;
    if (!PuzzleRules.canMove(state.board, event.row, event.col)) return;
    final moved = PuzzleRules.move(state.board, event.row, event.col);
    final solved = PuzzleRules.isSolved(moved);
    emit(
      state.copyWith(board: moved, moves: state.moves + 1, completed: solved),
    );
    if (solved) {
      _timer?.cancel();
    }
  }

  void _onReset(PuzzleReset event, Emitter<PuzzleGameState> emit) {
    emit(
      state.copyWith(
        board: state.initialBoard.map((e) => [...e]).toList(),
        moves: 0,
        seconds: 0,
        completed: false,
      ),
    );
  }

  void _onArrowMove(PuzzleArrowMove event, Emitter<PuzzleGameState> emit) {
    final empty = PuzzleRules.findEmpty(state.board);
    late final int targetRow;
    late final int targetCol;
    switch (event.direction) {
      case ArrowDirection.down:
        targetRow = empty.row - 1;
        targetCol = empty.col;
      case ArrowDirection.left:
        targetRow = empty.row;
        targetCol = empty.col + 1;
      case ArrowDirection.up:
        targetRow = empty.row + 1;
        targetCol = empty.col;
      case ArrowDirection.right:
        targetRow = empty.row;
        targetCol = empty.col - 1;
    }
    if (targetRow < 0 ||
        targetCol < 0 ||
        targetRow >= state.board.length ||
        targetCol >= state.board.length) {
      return;
    }
    add(PuzzleTileTapped(targetRow, targetCol));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
