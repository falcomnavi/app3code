import 'package:flutter/material.dart';

class AppTheme {
  // Cores do tema claro
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFF03A9F4);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF43A047);
  static const Color warningColor = Color(0xFFFFA000);

  // Cores do tema escuro
  static const Color darkPrimaryColor = Color(0xFF90CAF9);
  static const Color darkAccentColor = Color(0xFF64B5F6);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkTextColor = Color(0xFFE0E0E0);
  static const Color darkSecondaryTextColor = Color(0xFF9E9E9E);
  static const Color darkErrorColor = Color(0xFFEF5350);
  static const Color darkSuccessColor = Color(0xFF66BB6A);
  static const Color darkWarningColor = Color(0xFFFFB74D);

  // Gradiente de fundo
  static BoxDecoration get gradientBackground => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withOpacity(0.1),
            accentColor.withOpacity(0.1),
          ],
        ),
      );

  // Tema claro
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: accentColor,
          surface: surfaceColor,
          background: backgroundColor,
          error: errorColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        cardColor: surfaceColor,
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: textColor),
          displayMedium: TextStyle(color: textColor),
          displaySmall: TextStyle(color: textColor),
          headlineLarge: TextStyle(color: textColor),
          headlineMedium: TextStyle(color: textColor),
          headlineSmall: TextStyle(color: textColor),
          titleLarge: TextStyle(color: textColor),
          titleMedium: TextStyle(color: textColor),
          titleSmall: TextStyle(color: textColor),
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
          bodySmall: TextStyle(color: secondaryTextColor),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceColor,
          foregroundColor: textColor,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: surfaceColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
        ),
        iconTheme: const IconThemeData(
          color: primaryColor,
        ),
      );

  // Tema escuro
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: darkPrimaryColor,
          secondary: darkAccentColor,
          surface: darkSurfaceColor,
          background: darkBackgroundColor,
          error: darkErrorColor,
        ),
        scaffoldBackgroundColor: darkBackgroundColor,
        cardColor: darkSurfaceColor,
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: darkTextColor),
          displayMedium: TextStyle(color: darkTextColor),
          displaySmall: TextStyle(color: darkTextColor),
          headlineLarge: TextStyle(color: darkTextColor),
          headlineMedium: TextStyle(color: darkTextColor),
          headlineSmall: TextStyle(color: darkTextColor),
          titleLarge: TextStyle(color: darkTextColor),
          titleMedium: TextStyle(color: darkTextColor),
          titleSmall: TextStyle(color: darkTextColor),
          bodyLarge: TextStyle(color: darkTextColor),
          bodyMedium: TextStyle(color: darkTextColor),
          bodySmall: TextStyle(color: darkSecondaryTextColor),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: darkSurfaceColor,
          foregroundColor: darkTextColor,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: darkSurfaceColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPrimaryColor,
            foregroundColor: darkBackgroundColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: darkPrimaryColor,
          ),
        ),
        iconTheme: const IconThemeData(
          color: darkPrimaryColor,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: darkSurfaceColor,
          titleTextStyle: const TextStyle(
            color: darkTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: darkSecondaryTextColor,
            fontSize: 16,
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: darkSurfaceColor,
          modalBackgroundColor: darkSurfaceColor,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: darkSurfaceColor,
          contentTextStyle: const TextStyle(color: darkTextColor),
        ),
      );

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
} 