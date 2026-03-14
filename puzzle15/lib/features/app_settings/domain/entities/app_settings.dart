import 'package:flutter/material.dart';

enum TileVisualMode { numberOnly, imageOnly, numberAndImage }

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.tileVisualMode,
    required this.tileImages,
  });

  final ThemeMode themeMode;
  final TileVisualMode tileVisualMode;
  final List<String> tileImages;

  AppSettings copyWith({
    ThemeMode? themeMode,
    TileVisualMode? tileVisualMode,
    List<String>? tileImages,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      tileVisualMode: tileVisualMode ?? this.tileVisualMode,
      tileImages: tileImages ?? this.tileImages,
    );
  }
}
