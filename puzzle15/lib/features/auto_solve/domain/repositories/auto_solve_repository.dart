import 'package:dartz/dartz.dart';

import 'package:puzzle15/core/error/failures.dart';

abstract class AutoSolveRepository {
  Future<Either<Failure, Unit>> checkStatus();
  Future<Either<Failure, List<String>>> solve(List<List<int>> puzzle);
}
