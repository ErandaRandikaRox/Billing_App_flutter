import 'package:billing_app/theme/custom_themes/appbar_theme.dart';
import 'package:billing_app/theme/custom_themes/checkbox_theme.dart';
import 'package:billing_app/theme/custom_themes/elevated_button_theme.dart';
import 'package:billing_app/theme/custom_themes/list_tile_theme.dart';
import 'package:billing_app/theme/custom_themes/navigation_bar_theme.dart';
import 'package:billing_app/theme/custom_themes/outlined_button_theme.dart';
import 'package:billing_app/theme/custom_themes/switch_list_theme.dart';
import 'package:billing_app/theme/custom_themes/text_field_theme.dart';
import 'package:billing_app/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class MyAppTheme {
  MyAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    primaryColor: const Color(0xFF1976D2), // Blue
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1976D2), // Blue
      secondary: Color(0xFF26A69A), // Teal
      surface: Color(0xFFFFFFFF), // White for cards
      background: Color(0xFFF5F5F5), // Off-white
      error: Color(0xFFD32F2F), // Red
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF212121), // Dark gray for text
      onBackground: Color(0xFF212121),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Off-white
    cardColor: const Color(0xFFFFFFFF), // White
    dividerColor: const Color(0xFFE0E0E0), // Light gray
    textTheme: MyTextTheme.lightTextTheme,
    appBarTheme: MyAppBarTheme.lightAppBarTheme,
    checkboxTheme: MyCheckBoxtheme.lightCheckBoxTheme,
    elevatedButtonTheme: MyElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: MyOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: MyTextFormFieldTheme.lightInputDecorationTheme,
    bottomNavigationBarTheme: MyNavigationBarTheme.lightNavigationBarTheme,
    listTileTheme: MyListTileTheme.lightListTileTheme,
    switchTheme: MySwitchListTileTheme.lightSwitchTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF42A5F5), // Lighter blue
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF42A5F5), // Lighter blue
      secondary: Color(0xFF4DB6AC), // Muted teal
      surface: Color(0xFF1E1E1E), // Dark gray for cards
      background: Color(0xFF121212), // Dark background
      error: Color(0xFFEF5350), // Softer red
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Color(0xFFE0E0E0), // Off-white for text
      onBackground: Color(0xFFE0E0E0),
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212), // Dark background
    cardColor: const Color(0xFF1E1E1E), // Dark gray
    dividerColor: const Color(0xFF424242), // Darker gray
    textTheme: MyTextTheme.darkTextTheme,
    appBarTheme: MyAppBarTheme.darkAppBarTheme,
    checkboxTheme: MyCheckBoxtheme.darkCheckBoxTheme,
    elevatedButtonTheme: MyElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: MyOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: MyTextFormFieldTheme.darkInputDecorationTheme,
    bottomNavigationBarTheme: MyNavigationBarTheme.darkNavigationBarTheme,
    listTileTheme: MyListTileTheme.darkListTileTheme,
    switchTheme: MySwitchListTileTheme.darkSwitchTheme,
  );
}
