import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puzzle15/features/auto_solve/domain/repositories/auto_solve_repository.dart';

sealed class AutoSolveEvent {}

class AutoSolveRequested extends AutoSolveEvent {
  AutoSolveRequested(this.board);
  final List<List<int>> board;
}

class AutoSolveStartedAnimation extends AutoSolveEvent {}

class AutoSolveSpeedChanged extends AutoSolveEvent {
  AutoSolveSpeedChanged(this.value);
  final double value;
}

class AutoSolveAdvanceStep extends AutoSolveEvent {}

class AutoSolveState {
  AutoSolveState({
    required this.loading,
    required this.board,
    required this.moves,
    required this.error,
    required this.canStart,
    required this.animating,
    required this.speed,
    required this.finished,
    required this.zeroPoint,
  });

  final bool loading;
  final List<List<int>> board;
  final List<String> moves;
  final String? error;
  final bool canStart;
  final bool animating;
  final double speed;
  final bool finished;
  ({int row, int col}) zeroPoint;

  factory AutoSolveState.initial(List<List<int>> board) {
    int zr = -1, zc = -1;
    for (var i = 0; zr == -1 && i < board.length; i++) {
      for (var j = 0; j < board[i].length; j++) {
        if (board[i][j] == 0) {
          zr = i;
          zc = j;
          break;
        }
      }
    }

    return AutoSolveState(
      loading: false,
      board: board,
      moves: const [],
      error: null,
      canStart: false,
      animating: false,
      speed: 0.5,
      finished: false,
      zeroPoint: (row: zr, col: zc),
    );
  }

  AutoSolveState copyWith({
    bool? loading,
    List<List<int>>? board,
    List<String>? moves,
    String? error,
    bool? canStart,
    bool? animating,
    double? speed,
    bool? finished,
    ({int row, int col})? zeroPoint,
    bool clearError = false,
  }) {
    return AutoSolveState(
      loading: loading ?? this.loading,
      board: board ?? this.board,
      moves: moves ?? this.moves,
      error: clearError ? null : error ?? this.error,
      canStart: canStart ?? this.canStart,
      animating: animating ?? this.animating,
      speed: speed ?? this.speed,
      finished: finished ?? this.finished,
      zeroPoint: zeroPoint ?? this.zeroPoint,
    );
  }
}

class AutoSolveBloc extends Bloc<AutoSolveEvent, AutoSolveState> {
  AutoSolveBloc(this._repository, List<List<int>> board)
    : super(AutoSolveState.initial(board)) {
    on<AutoSolveRequested>(_onRequested);
    on<AutoSolveStartedAnimation>(_onStartedAnimation);
    on<AutoSolveSpeedChanged>((event, emit) {
      emit(state.copyWith(speed: event.value));
      _restartTimer(speed: event.value);
    });
    on<AutoSolveAdvanceStep>(_onAdvanceStep);
  }

  final AutoSolveRepository _repository;
  Timer? _timer;
  int _step = 0;

  Future<void> _onRequested(
    AutoSolveRequested event,
    Emitter<AutoSolveState> emit,
  ) async {
    emit(state.copyWith(loading: true, canStart: false, clearError: true));
    final status = await _repository.checkStatus();
    final statusOk = status.fold((l) => false, (r) => true);
    if (!statusOk) {
      emit(state.copyWith(loading: false, error: 'Сервер недоступен'));
      return;
    }

    final result = await _repository.solve(event.board);
    result.fold(
      (failure) => emit(
        state.copyWith(loading: false, error: failure.message, canStart: false),
      ),
      (moves) =>
          emit(state.copyWith(loading: false, moves: moves, canStart: true)),
    );
  }

  void _onStartedAnimation(
    AutoSolveStartedAnimation event,
    Emitter<AutoSolveState> emit,
  ) {
    if (!state.canStart || state.moves.isEmpty) return;
    _step = 0;
    emit(state.copyWith(animating: true, canStart: false));
    _restartTimer();
  }

  void _restartTimer({double? speed}) {
    _timer?.cancel();
    final ms = (900 - (speed ?? state.speed) * 850).round().clamp(50, 900);
    _timer = Timer.periodic(
      Duration(milliseconds: ms),
      (_) => add(AutoSolveAdvanceStep()),
    );
  }

  void _onAdvanceStep(
    AutoSolveAdvanceStep event,
    Emitter<AutoSolveState> emit,
  ) {
    if (_step >= state.moves.length) {
      _timer?.cancel();
      emit(state.copyWith(animating: false, finished: true));
      return;
    }

    final move = state.moves[_step];
    final board = state.board.map((e) => [...e]).toList();

    int tileRow = state.zeroPoint.row;
    int tileCol = state.zeroPoint.col;

    if (move == "D") {
      tileRow--;
    } else if (move == "U") {
      tileRow++;
    } else if (move == "R") {
      tileCol--;
    } else if (move == "L") {
      tileCol++;
    } else {
      throw Exception("Unexpected move");
    }

    board[state.zeroPoint.row][state.zeroPoint.col] = board[tileRow][tileCol];
    board[tileRow][tileCol] = 0;
    emit(state.copyWith(board: board, zeroPoint: (row: tileRow, col: tileCol)));
    _step++;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
