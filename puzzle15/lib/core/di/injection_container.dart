import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:puzzle15/features/app_settings/data/repositories/settings_repository_impl.dart';
import 'package:puzzle15/features/app_settings/domain/repositories/settings_repository.dart';
import 'package:puzzle15/features/app_settings/presentation/bloc/settings_cubit.dart';
import 'package:puzzle15/features/auto_solve/data/datasources/auto_solve_remote_data_source.dart';
import 'package:puzzle15/features/auto_solve/data/repositories/auto_solve_repository_impl.dart';
import 'package:puzzle15/features/auto_solve/domain/repositories/auto_solve_repository.dart';
import 'package:puzzle15/features/auto_solve/presentation/bloc/auto_solve_bloc.dart';
import 'package:puzzle15/features/weekly_puzzle/data/datasources/weekly_remote_data_source.dart';
import 'package:puzzle15/features/weekly_puzzle/data/repositories/weekly_repository_impl.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/repositories/weekly_repository.dart';
import 'package:puzzle15/features/weekly_puzzle/presentation/bloc/weekly_calendar_bloc.dart';
import 'package:puzzle15/core/network/api_client.dart';
import 'package:puzzle15/core/storage/app_prefs.dart';
import 'package:puzzle15/core/storage/weekly_progress_storage.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt.registerLazySingleton(() => prefs);
  getIt.registerLazySingleton(() => AppPrefs(getIt()));
  getIt.registerLazySingleton(() => WeeklyProgressStorage(getIt()));
  getIt.registerLazySingleton(ApiClient.new);

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => SettingsCubit(getIt()));

  getIt.registerLazySingleton(() => WeeklyRemoteDataSource(getIt()));
  getIt.registerLazySingleton<WeeklyRepository>(
    () => WeeklyRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerFactory(() => WeeklyCalendarBloc(getIt()));

  getIt.registerLazySingleton(() => AutoSolveRemoteDataSource(getIt()));
  getIt.registerLazySingleton<AutoSolveRepository>(
    () => AutoSolveRepositoryImpl(getIt()),
  );
  getIt.registerFactoryParam<AutoSolveBloc, List<List<int>>, void>(
    (board, _) => AutoSolveBloc(getIt(), board),
  );
}
