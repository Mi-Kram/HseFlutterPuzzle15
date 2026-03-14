import 'package:flutter/material.dart';

import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/core/di/injection_container.dart';
import 'package:puzzle15/features/weekly_puzzle/domain/repositories/weekly_repository.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key, required this.args});

  final ResultRouteArgs args;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Уровень пройден!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text('Время: ${args.seconds} сек'),
              Text('Ходы: ${args.moves}'),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final fixedWeeklyDate = args.weeklyDate;
                  if (fixedWeeklyDate != null) {
                    final repository = getIt<WeeklyRepository>();

                    await repository.saveResult(
                      year: fixedWeeklyDate.year,
                      month: fixedWeeklyDate.month,
                      day: fixedWeeklyDate.day,
                      moves: args.moves,
                      seconds: args.seconds,
                    );
                  }

                  if (!context.mounted) return;

                  if (fixedWeeklyDate != null) {
                    Navigator.pop(context, true);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.home,
                      (route) => route.isFirst,
                    );
                  }
                },
                child: const Text('Продолжить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
