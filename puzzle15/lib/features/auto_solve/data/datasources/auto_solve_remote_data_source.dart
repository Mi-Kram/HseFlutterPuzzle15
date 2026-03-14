import 'package:dio/dio.dart';

import 'package:puzzle15/core/error/exceptions.dart';
import 'package:puzzle15/core/network/api_client.dart';

class AutoSolveRemoteDataSource {
  AutoSolveRemoteDataSource(this._client);

  final ApiClient _client;

  Future<void> checkStatus() async {
    try {
      await _client.dio.get('/status');
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Сервер недоступен');
    }
  }

  Future<List<String>> solve(List<List<int>> puzzle) async {
    try {
      final response = await _client.dio.post(
        '/api/puzzle/solve',
        data: {'puzzle': puzzle},
      );
      return (response.data['moves'] as List).map((e) => e as String).toList();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Ошибка автосборки');
    }
  }
}
