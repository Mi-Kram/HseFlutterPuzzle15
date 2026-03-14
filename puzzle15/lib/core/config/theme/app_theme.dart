import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryLight = Color.fromARGB(255, 167, 121, 208);
  static const Color primaryDark = Color.fromARGB(255, 94, 63, 124);

  const AppTheme._();

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
    ),
    scaffoldBackgroundColor: Colors.white,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Colors.white,
    ),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 2,
      actionsPadding: EdgeInsets.symmetric(horizontal: 10),
    ),
    scaffoldBackgroundColor: const Color.fromARGB(255, 30, 30, 30),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryLight,
      foregroundColor: Colors.black,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white70,
      indicatorColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: const Color.fromARGB(255, 40, 40, 40),
      elevation: 0,
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: Color.fromARGB(255, 40, 40, 40),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color.fromARGB(255, 40, 40, 40),
    ),
  );
}
