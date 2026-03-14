import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';
import 'package:puzzle15/features/app_settings/domain/repositories/settings_repository.dart';

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.tileMode,
    required this.tileImages,
    this.loading = false,
  });

  final ThemeMode themeMode;
  final TileVisualMode tileMode;
  final List<String> tileImages;
  final bool loading;

  SettingsState copyWith({
    ThemeMode? themeMode,
    TileVisualMode? tileMode,
    List<String>? tileImages,
    bool? loading,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      tileMode: tileMode ?? this.tileMode,
      tileImages: tileImages ?? this.tileImages,
      loading: loading ?? this.loading,
    );
  }
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository)
    : super(
        const SettingsState(
          themeMode: ThemeMode.system,
          tileMode: TileVisualMode.numberAndImage,
          tileImages: [],
        ),
      );

  final SettingsRepository _repository;

  Future<void> load() async {
    final settings = await _repository.getSettings();
    emit(
      state.copyWith(
        themeMode: settings.themeMode,
        tileMode: settings.tileVisualMode,
        tileImages: settings.tileImages,
      ),
    );
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _repository.saveThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setTileMode(TileVisualMode mode) async {
    await _repository.saveTileVisualMode(mode);
    emit(state.copyWith(tileMode: mode));
  }

  Future<void> setTileImages(List<String> images) async {
    await _repository.saveTileImages(images);
    emit(state.copyWith(tileImages: images));
  }

  Future<void> saveTileImage(String key, String image) async {
    await _repository.saveTileImage(key, image);
  }

  Future<void> deleteTileImage(String key) async {
    await _repository.deleteTileImage(key);
  }

  String? getTileImage(String key) {
    return _repository.getTileImage(key);
  }
}
