import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/core/widgets/settings_action_button.dart';
import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';
import 'package:puzzle15/features/app_settings/presentation/bloc/settings_cubit.dart';
import 'package:puzzle15/features/puzzle_game/presentation/bloc/puzzle_game_bloc.dart';
import 'package:puzzle15/features/puzzle_game/presentation/widgets/puzzle_grid.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({super.key, required this.args});

  final PuzzleRouteArgs args;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();

    final imageData = cubit.state.tileImages.isNotEmpty
        ? cubit.getTileImage(
            cubit.state.tileImages[Random().nextInt(
              cubit.state.tileImages.length,
            )],
          )
        : null;

    return BlocProvider(
      create: (ctx) {
        return PuzzleGameBloc()..add(PuzzleStarted(args.puzzle, imageData));
      },
      child: _PuzzleView(args: args),
    );
  }
}

class _PuzzleView extends StatefulWidget {
  const _PuzzleView({required this.args});

  final PuzzleRouteArgs args;

  @override
  State<_PuzzleView> createState() => _PuzzleViewState();
}

class _PuzzleViewState extends State<_PuzzleView> with WidgetsBindingObserver {
  bool _pausedByLifecycle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    final bloc = context.read<PuzzleGameBloc>();
    final PuzzleGameState gameState = bloc.state;

    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (!gameState.paused && !gameState.completed) {
          bloc.add(PuzzlePaused());
          _pausedByLifecycle = true;
        }
        break;

      case AppLifecycleState.resumed:
        if (_pausedByLifecycle && !gameState.completed) {
          bloc.add(PuzzleResumed());
          _pausedByLifecycle = false;
        }
        break;

      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _confirmExit(BuildContext context) async {
    final shouldLeave =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Выйти из игры?'),
              content: const Text(
                'Текущий прогресс этого прохождения будет потерян.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Остаться'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: const Text('Выйти'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!context.mounted) return;
    if (shouldLeave) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PuzzleGameBloc, PuzzleGameState>(
      listenWhen: (prev, next) => !prev.completed && next.completed,
      listener: (context, state) async {
        final res = await Navigator.pushNamed(
          context,
          AppRouter.result,
          arguments: ResultRouteArgs(
            moves: state.moves,
            seconds: state.seconds,
            weeklyDate: widget.args.weeklyDate,
          ),
        );

        if (!context.mounted) return;
        Navigator.pop(context, res);
      },
      child: Shortcuts(
        shortcuts: {
          const SingleActivator(LogicalKeyboardKey.arrowDown):
              const DirectionIntent(ArrowDirection.down),
          const SingleActivator(LogicalKeyboardKey.arrowLeft):
              const DirectionIntent(ArrowDirection.left),
          const SingleActivator(LogicalKeyboardKey.arrowUp):
              const DirectionIntent(ArrowDirection.up),
          const SingleActivator(LogicalKeyboardKey.arrowRight):
              const DirectionIntent(ArrowDirection.right),
        },
        child: Actions(
          actions: {
            DirectionIntent: CallbackAction<DirectionIntent>(
              onInvoke: (intent) {
                context.read<PuzzleGameBloc>().add(
                  PuzzleArrowMove(intent.direction),
                );
                return null;
              },
            ),
          },
          child: Focus(
            autofocus: true,
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) async {
                if (didPop) return;

                context.read<PuzzleGameBloc>().add(PuzzlePaused());
                await _confirmExit(context);

                if (context.mounted) {
                  context.read<PuzzleGameBloc>().add(PuzzleResumed());
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  title: widget.args.isWeekly
                      ? Text(
                          'Задание ${DateFormat('yyyy.MM.dd').format(widget.args.weeklyDate ?? DateTime.now())}',
                        )
                      : const Text('Головоломка'),
                  actions: [
                    BlocBuilder<PuzzleGameBloc, PuzzleGameState>(
                      builder: (context, state) {
                        return IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () =>
                              context.read<PuzzleGameBloc>().add(PuzzleReset()),
                        );
                      },
                    ),
                    if (!widget.args.isWeekly)
                      IconButton(
                        icon: const Icon(Icons.auto_fix_high),
                        onPressed: () {
                          final state = context.read<PuzzleGameBloc>().state;
                          context.read<PuzzleGameBloc>().add(PuzzlePaused());
                          Navigator.pushNamed(
                            context,
                            AppRouter.autoSolve,
                            arguments: AutoSolveRouteArgs(board: state.board),
                          ).then((_) {
                            if (context.mounted) {
                              context.read<PuzzleGameBloc>().add(
                                PuzzleResumed(),
                              );
                            }
                          });
                        },
                      ),
                    SettingsActionButton(
                      onOpen: () =>
                          context.read<PuzzleGameBloc>().add(PuzzlePaused()),
                      onClose: () =>
                          context.read<PuzzleGameBloc>().add(PuzzleResumed()),
                    ),
                  ],
                ),
                body: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocSelector<PuzzleGameBloc, PuzzleGameState, int>(
                        selector: (state) => state.seconds,
                        builder: (context, seconds) {
                          return Text('Время: $seconds сек');
                        },
                      ),
                      const SizedBox(height: 8),
                      BlocSelector<PuzzleGameBloc, PuzzleGameState, int>(
                        selector: (state) => state.moves,
                        builder: (context, moves) {
                          return Text('Ходы: $moves');
                        },
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final gridSize =
                                constraints.maxWidth < constraints.maxHeight
                                ? constraints.maxWidth
                                : constraints.maxHeight;

                            return Center(
                              child: SizedBox(
                                width: gridSize,
                                height: gridSize,
                                child:
                                    BlocBuilder<
                                      PuzzleGameBloc,
                                      PuzzleGameState
                                    >(
                                      buildWhen: (previous, current) =>
                                          previous.board != current.board ||
                                          previous.imageData !=
                                              current.imageData,
                                      builder: (context, state) {
                                        return BlocSelector<
                                          SettingsCubit,
                                          SettingsState,
                                          TileVisualMode
                                        >(
                                          selector: (state) => state.tileMode,
                                          builder: (context, mode) {
                                            final settingsCubit = context
                                                .watch<SettingsCubit>();
                                            final gameBloc = context
                                                .read<PuzzleGameBloc>();

                                            if (mode ==
                                                    TileVisualMode.numberOnly ||
                                                settingsCubit
                                                    .state
                                                    .tileImages
                                                    .isEmpty) {
                                              gameBloc.add(
                                                PuzzleImageChanged(null),
                                              );
                                            } else {
                                              gameBloc.add(
                                                PuzzleImageChanged(
                                                  settingsCubit.getTileImage(
                                                    settingsCubit
                                                        .state
                                                        .tileImages[Random()
                                                        .nextInt(
                                                          settingsCubit
                                                              .state
                                                              .tileImages
                                                              .length,
                                                        )],
                                                  ),
                                                ),
                                              );
                                            }

                                            return PuzzleGrid(
                                              board: gameBloc.state.board,
                                              tileMode:
                                                  settingsCubit.state.tileMode,
                                              imageData:
                                                  gameBloc.state.imageData,
                                              onTap: (row, col) => context
                                                  .read<PuzzleGameBloc>()
                                                  .add(
                                                    PuzzleTileTapped(row, col),
                                                  ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DirectionIntent extends Intent {
  const DirectionIntent(this.direction);
  final ArrowDirection direction;
}
