import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';
import 'package:puzzle15/features/app_settings/presentation/bloc/settings_cubit.dart';

import '../../helpers/mocks.dart';

void main() {
  late MockSettingsRepository repository;
  late SettingsCubit cubit;

  setUpAll(() {
    registerFallbackValue(
      const AppSettings(
        themeMode: ThemeMode.system,
        tileVisualMode: TileVisualMode.numberAndImage,
        tileImages: [],
      ),
    );
  });

  setUp(() {
    repository = MockSettingsRepository();
    cubit = SettingsCubit(repository);
  });

  test('load emits repository values', () async {
    when(() => repository.getSettings()).thenAnswer(
      (_) async => const AppSettings(
        themeMode: ThemeMode.dark,
        tileVisualMode: TileVisualMode.imageOnly,
        tileImages: ['a', 'b'],
      ),
    );

    await cubit.load();

    expect(cubit.state.themeMode, ThemeMode.dark);
    expect(cubit.state.tileMode, TileVisualMode.imageOnly);
    expect(cubit.state.tileImages, ['a', 'b']);
  });

  test('setTheme updates state', () async {
    when(
      () => repository.saveThemeMode(ThemeMode.light),
    ).thenAnswer((_) async {});

    await cubit.setTheme(ThemeMode.light);

    expect(cubit.state.themeMode, ThemeMode.light);
  });

  test('setTileMode updates state', () async {
    when(
      () => repository.saveTileVisualMode(TileVisualMode.numberOnly),
    ).thenAnswer((_) async {});

    await cubit.setTileMode(TileVisualMode.numberOnly);

    expect(cubit.state.tileMode, TileVisualMode.numberOnly);
  });

  test('setTileImages updates state', () async {
    when(() => repository.saveTileImages(['x', 'y'])).thenAnswer((_) async {});

    await cubit.setTileImages(['x', 'y']);

    expect(cubit.state.tileImages, ['x', 'y']);
  });
}
