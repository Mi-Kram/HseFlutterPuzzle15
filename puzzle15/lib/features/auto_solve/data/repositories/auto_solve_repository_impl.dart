import 'package:dartz/dartz.dart';

import 'package:puzzle15/core/error/exceptions.dart';
import 'package:puzzle15/core/error/failures.dart';
import 'package:puzzle15/features/auto_solve/domain/repositories/auto_solve_repository.dart';
import 'package:puzzle15/features/auto_solve/data/datasources/auto_solve_remote_data_source.dart';

class AutoSolveRepositoryImpl implements AutoSolveRepository {
  AutoSolveRepositoryImpl(this._remote);

  final AutoSolveRemoteDataSource _remote;

  @override
  Future<Either<Failure, Unit>> checkStatus() async {
    try {
      await _remote.checkStatus();
      return const Right(unit);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<String>>> solve(List<List<int>> puzzle) async {
    try {
      return Right(await _remote.solve(puzzle));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
