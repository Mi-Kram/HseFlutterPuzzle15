import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';
import 'package:puzzle15/features/puzzle_game/presentation/widgets/num_button.dart';

class PuzzleGrid extends StatelessWidget {
  const PuzzleGrid({
    super.key,
    required this.board,
    required this.tileMode,
    required this.onTap,
    this.imageData,
  });

  final List<List<int>> board;
  final TileVisualMode tileMode;
  final String? imageData;
  final void Function(int row, int col) onTap;

  @override
  Widget build(BuildContext context) {
    final size = board.length;

    if (size <= 0) {
      return const Center(child: CircularProgressIndicator());
    }

    Uint8List? imageBytes;
    final fixedImageData = imageData;
    if (fixedImageData != null && fixedImageData.isNotEmpty) {
      try {
        imageBytes = base64Decode(fixedImageData);
      } catch (_) {
        imageBytes = null;
      }
    }

    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = 4.0;
          final tileSize = (constraints.maxWidth - gap * (size - 1)) / size;

          final tiles = <Widget>[];

          for (var row = 0; row < size; row++) {
            for (var col = 0; col < size; col++) {
              final value = board[row][col];
              if (value == 0) continue;

              tiles.add(
                AnimatedPositioned(
                  key: ValueKey(value),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeInOut,
                  left: col * (tileSize + gap),
                  top: row * (tileSize + gap),
                  width: tileSize,
                  height: tileSize,
                  child: RepaintBoundary(
                    child: NumButton(
                      number: value,
                      imageBytes: imageBytes,
                      mode: tileMode,
                      size: size,
                      row: row,
                      col: col,
                      onTap: () => onTap(row, col),
                    ),
                  ),
                ),
              );
            }
          }

          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxWidth,
            child: Stack(children: tiles),
          );
        },
      ),
    );
  }
}
