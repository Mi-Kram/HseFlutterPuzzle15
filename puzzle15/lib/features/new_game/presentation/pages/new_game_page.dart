import 'package:flutter/material.dart';

import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/core/puzzle/puzzle_generator.dart';
import 'package:puzzle15/core/widgets/settings_action_button.dart';

class NewGamePage extends StatelessWidget {
  const NewGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новая игра'),
        actions: const [SettingsActionButton()],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final size = index + 3;
          return Card(
            child: ListTile(
              title: Text('$size x $size'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                final puzzle = PuzzleGenerator.generate(size);
                Navigator.pushNamed(
                  context,
                  AppRouter.puzzle,
                  arguments: PuzzleRouteArgs(
                    puzzle: puzzle,
                    size: size,
                    isWeekly: false,
                    weeklyDate: null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
