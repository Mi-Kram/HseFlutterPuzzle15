import 'package:flutter/material.dart';

import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveThemeMode(ThemeMode mode);
  Future<void> saveTileVisualMode(TileVisualMode mode);
  Future<void> saveTileImages(List<String> paths);
  Future<void> saveTileImage(String key, String image);
  Future<void> deleteTileImage(String key);
  String? getTileImage(String key);
}
