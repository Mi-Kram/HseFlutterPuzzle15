import 'package:dio/dio.dart';

import 'package:puzzle15/core/error/exceptions.dart';
import 'package:puzzle15/core/network/api_client.dart';

class WeeklyRemoteDataSource {
  WeeklyRemoteDataSource(this._client);

  final ApiClient _client;

  Future<({int year, int month, int day})> getMinDate() async {
    try {
      final response = await _client.dio.get('/api/puzzle/min');
      return (
        year: response.data['year'] as int,
        month: response.data['month'] as int,
        day: response.data['day'] as int,
      );
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to get min date');
    }
  }

  Future<List<List<int>>> getPuzzle({
    required int year,
    required int month,
    required int day,
  }) async {
    try {
      final response = await _client.dio.get('/api/puzzle/$year/$month/$day');
      final raw = response.data['puzzle'] as List<dynamic>;
      return raw
          .map((row) => (row as List).map((e) => e as int).toList())
          .toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to get puzzle');
    }
  }
}
