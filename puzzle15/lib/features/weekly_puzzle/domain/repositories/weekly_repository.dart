import 'package:dartz/dartz.dart';

import 'package:puzzle15/core/error/failures.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/entities/weekly_puzzle_day.dart';

abstract class WeeklyRepository {
  Future<Either<Failure, ({int year, int month, int day})>> getMinDate();
  Future<Either<Failure, List<List<int>>>> getPuzzle({
    required int year,
    required int month,
    required int day,
  });
  Future<List<WeeklyPuzzleDay>> getMonthProgress(int year, int month);
  Future<void> saveResult({
    required int year,
    required int month,
    required int day,
    required int moves,
    required int seconds,
  });
}
