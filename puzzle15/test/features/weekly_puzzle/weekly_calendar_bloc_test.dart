import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:puzzle15/core/error/failures.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/entities/weekly_puzzle_day.dart';
import 'package:puzzle15/features/weekly_puzzle/presentation/bloc/weekly_calendar_bloc.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockWeeklyRepository repository;

  setUp(() {
    repository = MockWeeklyRepository();
  });

  group('WeeklyCalendarBloc', () {
    blocTest<WeeklyCalendarBloc, WeeklyCalendarState>(
      'started emits loaded state',
      build: () {
        when(
          () => repository.getMinDate(),
        ).thenAnswer((_) async => const Right((year: 2025, month: 1, day: 1)));
        when(() => repository.getMonthProgress(any(), any())).thenAnswer(
          (_) async => [
            WeeklyPuzzleDay(date: DateTime(2025, 3, 1), completed: false),
            WeeklyPuzzleDay(
              date: DateTime(2025, 3, 2),
              completed: true,
              moves: 30,
              seconds: 100,
            ),
          ],
        );
        return WeeklyCalendarBloc(repository);
      },
      act: (bloc) => bloc.add(WeeklyCalendarStarted()),
      expect: () => [
        isA<WeeklyCalendarState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.days.length, 'days length', 2),
      ],
    );

    blocTest<WeeklyCalendarBloc, WeeklyCalendarState>(
      'started emits failure state on error',
      build: () {
        when(
          () => repository.getMinDate(),
        ).thenAnswer((_) async => const Left(ServerFailure('boom')));
        return WeeklyCalendarBloc(repository);
      },
      act: (bloc) => bloc.add(WeeklyCalendarStarted()),
      expect: () => [
        isA<WeeklyCalendarState>()
            .having((s) => s.loading, 'loading', false)
            .having((s) => s.failure?.message, 'failure', 'boom'),
      ],
    );
  });
}
