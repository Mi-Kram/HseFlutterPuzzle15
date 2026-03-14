import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:puzzle15/core/config/app_router.dart';

import 'package:puzzle15/core/di/injection_container.dart';
import 'package:puzzle15/features/app_settings/presentation/bloc/settings_cubit.dart';
import 'package:puzzle15/features/puzzle_game/presentation/widgets/puzzle_grid.dart';
import 'package:puzzle15/features/auto_solve/presentation/bloc/auto_solve_bloc.dart';

class AutoSolvePage extends StatelessWidget {
  const AutoSolvePage({super.key, required this.args});

  final AutoSolveRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AutoSolveBloc>(param1: args.board)
            ..add(AutoSolveRequested(args.board)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Автосборка')),
        body: BlocConsumer<AutoSolveBloc, AutoSolveState>(
          listener: (context, state) {
            if (state.error != null && !state.animating && !state.canStart) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error ?? "error")));
            }
          },
          builder: (context, state) {
            final tileMode = context.watch<SettingsCubit>().state.tileMode;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                            child: PuzzleGrid(
                              board: state.board,
                              tileMode: tileMode,
                              onTap: (_, __) {},
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (state.loading)
                    FilledButton.icon(
                      onPressed: null,
                      icon: const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      label: const Text('Собрать'),
                    )
                  else if (state.error != null && !state.finished)
                    FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Продолжить'),
                    )
                  else if (state.canStart)
                    FilledButton(
                      onPressed: () => context.read<AutoSolveBloc>().add(
                        AutoSolveStartedAnimation(),
                      ),
                      child: const Text('Собрать'),
                    )
                  else if (state.finished)
                    FilledButton(
                      onPressed: () =>
                          Navigator.popUntil(context, (route) => route.isFirst),
                      child: const Text('Продолжить'),
                    ),
                  if (state.animating) ...[
                    const SizedBox(height: 24),
                    Slider(
                      value: state.speed,
                      onChanged: (value) => context.read<AutoSolveBloc>().add(
                        AutoSolveSpeedChanged(value),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
