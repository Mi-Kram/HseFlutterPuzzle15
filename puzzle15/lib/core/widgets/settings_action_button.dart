import 'package:flutter/material.dart';

import '../config/app_router.dart';

class SettingsActionButton extends StatelessWidget {
  const SettingsActionButton({super.key, this.onOpen, this.onClose});

  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () async {
        onOpen?.call();
        await Navigator.pushNamed(context, AppRouter.settings);
        onClose?.call();
      },
    );
  }
}
