import 'package:dartz/dartz.dart';

import 'package:puzzle15/core/error/exceptions.dart';
import 'package:puzzle15/core/error/failures.dart';
import 'package:puzzle15/core/storage/weekly_progress_storage.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/entities/weekly_puzzle_day.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/repositories/weekly_repository.dart';
import 'package:puzzle15/features/weekly_puzzle/data/datasources/weekly_remote_data_source.dart';

class WeeklyRepositoryImpl implements WeeklyRepository {
  WeeklyRepositoryImpl(this._remote, this._storage);

  final WeeklyRemoteDataSource _remote;
  final WeeklyProgressStorage _storage;

  @override
  Future<Either<Failure, ({int year, int month, int day})>> getMinDate() async {
    try {
      return Right(await _remote.getMinDate());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<List<int>>>> getPuzzle({
    required int year,
    required int month,
    required int day,
  }) async {
    try {
      return Right(await _remote.getPuzzle(year: year, month: month, day: day));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<List<WeeklyPuzzleDay>> getMonthProgress(int year, int month) async {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final now = DateTime.now().toUtc();
    final items = <WeeklyPuzzleDay>[];
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (date.isAfter(DateTime(now.year, now.month, now.day))) break;
      final result = _storage.readResult(year: year, month: month, day: day);
      items.add(
        WeeklyPuzzleDay(
          date: date,
          completed: result != null,
          moves: result?.moves,
          seconds: result?.seconds,
        ),
      );
    }
    return items;
  }

  @override
  Future<void> saveResult({
    required int year,
    required int month,
    required int day,
    required int moves,
    required int seconds,
  }) {
    return _storage.saveResult(
      year: year,
      month: month,
      day: day,
      moves: moves,
      seconds: seconds,
    );
  }
}
