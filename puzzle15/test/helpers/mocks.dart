import 'package:mocktail/mocktail.dart';
import 'package:puzzle15/core/error/failures.dart';
import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';
import 'package:puzzle15/features/app_settings/domain/repositories/settings_repository.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/repositories/weekly_repository.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockWeeklyRepository extends Mock implements WeeklyRepository {}

class FakeFailure extends Fake implements Failure {}

class FakeAppSettings extends Fake implements AppSettings {}
