import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/core/di/injection_container.dart';
import 'package:puzzle15/core/storage/app_prefs.dart';
import 'package:puzzle15/core/widgets/settings_action_button.dart';
import 'package:puzzle15/features/onboarding/presentation/bloc/onboarding_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    _checkCompleted();
  }

  Future<void> _checkCompleted() async {
    final prefs = getIt<AppPrefs>();
    final done = prefs.getBool('onboarding_completed');

    if (done && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (done) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    }
  }

  static final _items = <({IconData icon, String title, String description})>[
    (
      icon: Icons.calendar_month,
      title: 'Еженедельные задания',
      description:
          'Каждую неделю доступны уровни в календаре. Пройденные задания отмечаются галочкой.',
    ),
    (
      icon: Icons.grid_view,
      title: 'Новая игра',
      description:
          'Можно запускать новую головоломку с размером от 3x3 до 9x9.',
    ),
    (
      icon: Icons.auto_fix_high,
      title: 'Автосборка',
      description:
          'Для обычных уровней доступна автосборка через серверное решение.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocConsumer<OnboardingCubit, OnboardingState>(
        listener: (context, state) async {
          if (state.completed) {
            await getIt<AppPrefs>().setBool('onboarding_completed', true);
            if (!context.mounted) return;
            Navigator.pushReplacementNamed(context, AppRouter.home);
          }
        },
        builder: (context, state) {
          final item = _items[state.index];
          return Scaffold(
            appBar: AppBar(
              title: const Text("Пятнашки"),
              actions: const [SettingsActionButton()],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, size: 96),
                  const SizedBox(height: 24),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(item.description, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.index == 0
                              ? null
                              : () => context.read<OnboardingCubit>().back(),
                          child: const Text('Назад'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.read<OnboardingCubit>().next(
                            _items.length,
                          ),
                          child: Text(
                            state.index == _items.length - 1
                                ? 'Завершить'
                                : 'Далее',
                          ),
                        ),
                      ),
                    ],
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
