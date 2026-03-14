import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzle15/core/config/app_router.dart';
import 'package:puzzle15/features/app_settings/presentation/bloc/settings_cubit.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget child, {
    required SettingsCubit settingsCubit,
  }) async {
    await pumpWidget(
      BlocProvider.value(
        value: settingsCubit,
        child: MaterialApp(
          theme: AppRouter.lightTheme,
          darkTheme: AppRouter.darkTheme,
          onGenerateRoute: AppRouter.onGenerateRoute,
          home: child,
        ),
      ),
    );
  }
}
