import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';

class NumButton extends StatelessWidget {
  const NumButton({
    super.key,
    required this.number,
    this.imageBytes,
    required this.mode,
    required this.row,
    required this.col,
    this.onTap,
    required this.size,
  });

  final int number;
  final int size;
  final Uint8List? imageBytes;
  final TileVisualMode mode;
  final int row;
  final int col;
  final VoidCallback? onTap;

  double _calculateFontSize(double buttonSize) {
    double baseFontSize = buttonSize * 0.6;

    final digitCount = (size * size).abs().toString().length;
    if (digitCount > 2) {
      baseFontSize *= 0.7;
    } else if (digitCount > 1) {
      baseFontSize *= 0.8;
    }

    return baseFontSize.clamp(12.0, double.infinity);
  }

  @override
  Widget build(BuildContext context) {
    if (number == 0) {
      return const Positioned.fill(
        child: ColoredBox(color: Colors.transparent),
      );
    }

    final img = imageBytes;
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonSize = constraints.maxWidth < constraints.maxHeight
              ? constraints.maxWidth
              : constraints.maxHeight;
          final borderRadius = BorderRadius.circular(buttonSize / 10);

          return Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onTap,
              child: Stack(
                children: [
                  if (img != null)
                    Positioned.fill(
                      child: _TileImagePart(
                        imageBytes: img,
                        tileValue: number,
                        puzzleSize: size,
                      ),
                    )
                  else
                    Image.asset("nums_background.png"),

                  if (mode != TileVisualMode.imageOnly)
                    Center(
                      child: Text(
                        '$number',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: _calculateFontSize(buttonSize),
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TileImagePart extends StatelessWidget {
  const _TileImagePart({
    required this.imageBytes,
    required this.tileValue,
    required this.puzzleSize,
  });

  final Uint8List imageBytes;
  final int tileValue;
  final int puzzleSize;

  @override
  Widget build(BuildContext context) {
    final solvedRow = (tileValue - 1) ~/ puzzleSize;
    final solvedCol = (tileValue - 1) % puzzleSize;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth;
        final tileHeight = constraints.maxHeight;

        final fullWidth = tileWidth * puzzleSize;
        final fullHeight = tileHeight * puzzleSize;

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: fullWidth,
            maxWidth: fullWidth,
            minHeight: fullHeight,
            maxHeight: fullHeight,
            child: Transform.translate(
              offset: Offset(-solvedCol * tileWidth, -solvedRow * tileHeight),
              child: Image.memory(
                imageBytes,
                width: fullWidth,
                height: fullHeight,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
