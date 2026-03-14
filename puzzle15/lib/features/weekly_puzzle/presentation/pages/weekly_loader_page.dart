import 'package:flutter/material.dart';

import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/core/di/injection_container.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/repositories/weekly_repository.dart';

class WeeklyLoaderPage extends StatefulWidget {
  const WeeklyLoaderPage({super.key, required this.date});

  final DateTime date;

  @override
  State<WeeklyLoaderPage> createState() => _WeeklyLoaderPageState();
}

class _WeeklyLoaderPageState extends State<WeeklyLoaderPage> {
  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final repository = getIt<WeeklyRepository>();

    final result = await repository.getPuzzle(
      year: widget.date.year,
      month: widget.date.month,
      day: widget.date.day,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
        Navigator.of(context).pop();
      },
      (puzzle) async {
        final res = await Navigator.pushNamed(
          context,
          AppRouter.puzzle,
          arguments: PuzzleRouteArgs(
            puzzle: puzzle,
            size: puzzle.length,
            isWeekly: true,
            weeklyDate: widget.date,
          ),
        );

        if (!mounted) return;
        Navigator.pop(context, res);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
