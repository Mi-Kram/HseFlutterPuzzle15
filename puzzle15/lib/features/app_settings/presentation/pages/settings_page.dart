import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:puzzle15/features/app_settings/domain/entities/app_settings.dart';
import 'package:puzzle15/features/app_settings/presentation/bloc/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Тема'),
              RadioGroup<ThemeMode>(
                groupValue: state.themeMode,
                onChanged: (value) => cubit.setTheme(value ?? ThemeMode.system),
                child: const Column(
                  children: [
                    RadioListTile(
                      title: Text('Системная'),
                      value: ThemeMode.system,
                    ),
                    RadioListTile(
                      title: Text('Светлая'),
                      value: ThemeMode.light,
                    ),
                    RadioListTile(title: Text('Тёмная'), value: ThemeMode.dark),
                  ],
                ),
              ),
              const Divider(),
              const Text('Тип плиток'),
              RadioGroup<TileVisualMode>(
                groupValue: state.tileMode,
                onChanged: (value) =>
                    cubit.setTileMode(value ?? TileVisualMode.numberAndImage),
                child: Column(
                  children: [
                    RadioListTile(
                      title: Text('Только номер'),
                      value: TileVisualMode.numberOnly,
                    ),
                    RadioListTile(
                      title: Text('Только картинка'),
                      value: TileVisualMode.imageOnly,
                      enabled: state.tileImages.isNotEmpty,
                    ),
                    RadioListTile(
                      title: Text('Номер и картинка'),
                      value: TileVisualMode.numberAndImage,
                    ),
                  ],
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Список картинок'),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (file == null) return;

                      final updated = [...state.tileImages, file.name];

                      late String image;
                      try {
                        final bytes = await file.readAsBytes();
                        image = base64Encode(bytes);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      }

                      await cubit.saveTileImage(file.name, image);
                      await cubit.setTileImages(updated);
                    },
                  ),
                ],
              ),
              ...state.tileImages.map(
                (title) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.image_outlined),
                    title: Text(title),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        await cubit.deleteTileImage(title);
                        final updated = [...state.tileImages]..remove(title);
                        await cubit.setTileImages(updated);
                        if (updated.isEmpty &&
                            state.tileMode == TileVisualMode.imageOnly) {
                          await cubit.setTileMode(
                            TileVisualMode.numberAndImage,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
