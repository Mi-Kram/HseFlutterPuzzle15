import 'package:flutter/material.dart';

import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/core/widgets/settings_action_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Пятнашки"),
        actions: const [SettingsActionButton()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2), // Увеличили верхний отступ
              const Icon(Icons.grid_4x4_rounded, size: 160),
              const SizedBox(
                height: 48,
              ), // Увеличили расстояние между иконкой и кнопками
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.weekly),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          56,
                        ), // Фиксированная высота
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ), // Внутренние отступы
                      ),
                      child: const Text(
                        'Еженедельные задания',
                        textAlign: TextAlign.center, // Центрирование текста
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRouter.newGame),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(
                          56,
                        ), // Фиксированная высота
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ), // Внутренние отступы
                      ),
                      child: const Text(
                        'Новая игра',
                        textAlign: TextAlign.center, // Центрирование текста
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(
                      56,
                    ), // Та же высота для всех кнопок
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Турнир · скоро',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(flex: 2), // Увеличили нижний отступ для баланса
            ],
          ),
        ),
      ),
    );
  }
}
