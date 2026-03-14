import 'package:flutter/material.dart';
import 'package:puzzle15/core/storage/app_prefs.dart';

import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';
import 'package:puzzle15/features/app_settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final AppPrefs _prefs;

  static const _themeKey = 'theme_mode';
  static const _tileModeKey = 'tile_mode';
  static const _tileImagesKey = 'tile_images';

  @override
  Future<AppSettings> getSettings() async {
    final themeRaw = _prefs.getString(_themeKey) ?? 'system';
    final tileRaw = _prefs.getString(_tileModeKey) ?? 'numberAndImage';
    final images = _prefs.getStringList(_tileImagesKey);

    return AppSettings(
      themeMode: switch (themeRaw) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      tileVisualMode: switch (tileRaw) {
        'numberOnly' => TileVisualMode.numberOnly,
        'imageOnly' => TileVisualMode.imageOnly,
        _ => TileVisualMode.numberAndImage,
      },
      tileImages: images,
    );
  }

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    };
    await _prefs.setString(_themeKey, raw);
  }

  @override
  Future<void> saveTileImages(List<String> paths) =>
      _prefs.setStringList(_tileImagesKey, paths);

  @override
  Future<void> saveTileImage(String key, String image) =>
      _prefs.setString(key, image);

  @override
  Future<void> deleteTileImage(String key) => _prefs.setString(key, "");

  @override
  String? getTileImage(String key) => _prefs.getString(key);

  @override
  Future<void> saveTileVisualMode(TileVisualMode mode) async {
    await _prefs.setString(_tileModeKey, mode.name);
  }
}
