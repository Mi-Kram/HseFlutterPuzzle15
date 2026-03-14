import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puzzle15/core/error/failures.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/entities/weekly_puzzle_day.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/repositories/weekly_repository.dart';

sealed class WeeklyCalendarEvent {}

class WeeklyCalendarStarted extends WeeklyCalendarEvent {}

class WeeklyCalendarMonthChanged extends WeeklyCalendarEvent {
  WeeklyCalendarMonthChanged(int year, int month) {
    final date = DateTime(year, month);
    this.year = date.year;
    this.month = date.month;
  }
  late final int year;
  late final int month;
}

class WeeklyCalendarDaySelected extends WeeklyCalendarEvent {
  WeeklyCalendarDaySelected(this.date);
  final DateTime date;
}

class WeeklyCalendarFinishedGame extends WeeklyCalendarEvent {
  WeeklyCalendarFinishedGame(this.date);
  final DateTime date;
}

class WeeklyCalendarStartLoading extends WeeklyCalendarEvent {}

class WeeklyCalendarStopLoading extends WeeklyCalendarEvent {}

class WeeklyCalendarState {
  const WeeklyCalendarState({
    required this.loading,
    this.failure,
    this.minDate,
    this.visibleMonth,
    this.days = const [],
    this.selectedDate,
  });

  final bool loading;
  final Failure? failure;
  final DateTime? minDate;
  final DateTime? visibleMonth;
  final List<WeeklyPuzzleDay> days;
  final DateTime? selectedDate;

  WeeklyCalendarState copyWith({
    bool? loading,
    Failure? failure,
    DateTime? minDate,
    DateTime? visibleMonth,
    List<WeeklyPuzzleDay>? days,
    DateTime? selectedDate,
    bool clearFailure = false,
  }) {
    return WeeklyCalendarState(
      loading: loading ?? this.loading,
      failure: clearFailure ? null : failure ?? this.failure,
      minDate: minDate ?? this.minDate,
      visibleMonth: visibleMonth ?? this.visibleMonth,
      days: days ?? this.days,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class WeeklyCalendarBloc
    extends Bloc<WeeklyCalendarEvent, WeeklyCalendarState> {
  WeeklyCalendarBloc(this._repository)
    : super(const WeeklyCalendarState(loading: true)) {
    on<WeeklyCalendarStarted>(_onStarted);
    on<WeeklyCalendarMonthChanged>(_onMonthChanged);
    on<WeeklyCalendarDaySelected>(_onDaySelected);
    on<WeeklyCalendarFinishedGame>(_onGameFinished);
    on<WeeklyCalendarStartLoading>(
      (_, emit) async => emit(state.copyWith(loading: true)),
    );
    on<WeeklyCalendarStopLoading>(
      (_, emit) async => emit(state.copyWith(loading: false)),
    );
  }

  final WeeklyRepository _repository;

  Future<void> _onStarted(
    WeeklyCalendarStarted event,
    Emitter<WeeklyCalendarState> emit,
  ) async {
    final minResult = await _repository.getMinDate();
    await minResult.fold(
      (failure) async => emit(state.copyWith(loading: false, failure: failure)),
      (min) async {
        final now = DateTime.now();
        final month = DateTime(now.year, now.month);
        final days = await _repository.getMonthProgress(
          month.year,
          month.month,
        );
        DateTime selected = days.lastOrNull?.date ?? month;
        for (var i = days.length - 1; 0 <= i; i--) {
          if (!days[i].completed) {
            selected = days[i].date;
            break;
          }
        }

        emit(
          state.copyWith(
            loading: false,
            minDate: DateTime(min.year, min.month, min.day),
            visibleMonth: month,
            days: days,
            selectedDate: selected,
            clearFailure: true,
          ),
        );
      },
    );
  }

  Future<void> _onGameFinished(
    WeeklyCalendarFinishedGame event,
    Emitter<WeeklyCalendarState> emit,
  ) async {
    if (state.visibleMonth?.year == event.date.year &&
        state.visibleMonth?.month == event.date.month) {
      final days = await _repository.getMonthProgress(
        event.date.year,
        event.date.month,
      );
      DateTime? selected = days.isNotEmpty ? days.first.date : null;
      for (var i = days.length - 1; 0 <= i; i--) {
        if (!days[i].completed) {
          selected = days[i].date;
          break;
        }
      }

      emit(
        state.copyWith(
          days: await _repository.getMonthProgress(
            event.date.year,
            event.date.month,
          ),
          selectedDate: selected,
        ),
      );
    }
  }

  Future<void> _onMonthChanged(
    WeeklyCalendarMonthChanged event,
    Emitter<WeeklyCalendarState> emit,
  ) async {
    final now = DateTime.now();
    final target = DateTime(event.year, event.month);
    final futureLimit = DateTime(now.year, now.month);
    if (target.isAfter(futureLimit)) return;
    if (state.minDate != null && target.isBefore(state.minDate!)) return;

    final days = await _repository.getMonthProgress(event.year, event.month);

    DateTime? selected = days.isNotEmpty ? days.first.date : null;
    for (var i = days.length - 1; 0 <= i; i--) {
      if (!days[i].completed) {
        selected = days[i].date;
        break;
      }
    }

    emit(
      state.copyWith(visibleMonth: target, days: days, selectedDate: selected),
    );
  }

  void _onDaySelected(
    WeeklyCalendarDaySelected event,
    Emitter<WeeklyCalendarState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date));
  }
}
