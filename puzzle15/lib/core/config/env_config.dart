import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  const EnvConfig._();

  static String get puzzleEndpoint {
    final value = dotenv.env['PUZZLE_ENDPOINT'];
    if (value == null || value.isEmpty) {
      throw Exception('PUZZLE_ENDPOINT is missing in .env');
    }
    return value;
  }
}
