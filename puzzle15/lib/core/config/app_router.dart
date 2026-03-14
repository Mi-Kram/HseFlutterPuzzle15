import 'package:flutter/material.dart';

import 'package:puzzle15/features/app_settings/presentation/pages/settings_page.dart';
import 'package:puzzle15/features/auto_solve/presentation/pages/auto_solve_page.dart';
import 'package:puzzle15/features/home/presentation/pages/home_page.dart';
import 'package:puzzle15/features/new_game/presentation/pages/new_game_page.dart';
import 'package:puzzle15/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:puzzle15/features/puzzle_game/presentation/pages/puzzle_page.dart';
import 'package:puzzle15/features/results/presentation/pages/result_page.dart';
import 'package:puzzle15/features/weekly_puzzle/presentation/pages/weekly_calendar_page.dart';
import 'package:puzzle15/features/weekly_puzzle/presentation/pages/weekly_loader_page.dart';
import 'theme/app_theme.dart';

class AppRouter {
  const AppRouter._();

  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const settings = '/settings';
  static const weekly = '/weekly';
  static const weeklyLoader = '/weekly-loader';
  static const newGame = '/new-game';
  static const puzzle = '/puzzle';
  static const autoSolve = '/auto-solve';
  static const result = '/result';

  static ThemeData get lightTheme => AppTheme.light();
  static ThemeData get darkTheme => AppTheme.dark();

  static Route<dynamic> onGenerateRoute(RouteSettings s) {
    switch (s.name) {
      case splash:
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case weekly:
        return MaterialPageRoute(builder: (_) => const WeeklyCalendarPage());
      case weeklyLoader:
        return MaterialPageRoute(
          builder: (_) => WeeklyLoaderPage(date: s.arguments as DateTime),
        );
      case newGame:
        return MaterialPageRoute(builder: (_) => const NewGamePage());
      case puzzle:
        return MaterialPageRoute(
          builder: (_) => PuzzlePage(args: s.arguments as PuzzleRouteArgs),
        );
      case autoSolve:
        return MaterialPageRoute(
          builder: (_) =>
              AutoSolvePage(args: s.arguments as AutoSolveRouteArgs),
        );
      case result:
        return MaterialPageRoute(
          builder: (_) => ResultPage(args: s.arguments as ResultRouteArgs),
        );
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
    }
  }
}

class PuzzleRouteArgs {
  PuzzleRouteArgs({
    required this.puzzle,
    required this.size,
    required this.isWeekly,
    required this.weeklyDate,
  });

  final List<List<int>> puzzle;
  final int size;
  final bool isWeekly;
  final DateTime? weeklyDate;
}

class AutoSolveRouteArgs {
  AutoSolveRouteArgs({required this.board});
  final List<List<int>> board;
}

class ResultRouteArgs {
  ResultRouteArgs({
    required this.moves,
    required this.seconds,
    required this.weeklyDate,
  });
  final int moves;
  final int seconds;
  final DateTime? weeklyDate;
}
