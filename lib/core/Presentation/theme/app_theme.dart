import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.mainBg,
    fontFamily: GoogleFonts.inter().fontFamily,

    colorScheme: const ColorScheme.light(
      surface:        AppColors.mainBg,
      onSurface:      AppColors.primaryText,
      primary:        AppColors.primaryText,
      onPrimary:      AppColors.active,
      surfaceVariant: AppColors.sidebarBg,
      outline:        AppColors.border,
    ),

    textTheme: TextTheme(
      // Map your Figma scale to Material slots
      headlineLarge:  AppTextStyles.heading.copyWith(fontSize: 24),
      headlineMedium: AppTextStyles.heading.copyWith(fontSize: 20),
      headlineSmall:  AppTextStyles.heading.copyWith(fontSize: 18),
      titleMedium:    AppTextStyles.heading.copyWith(fontSize: 16),
      bodyLarge:      AppTextStyles.body.copyWith(fontSize: 16),
      bodyMedium:     AppTextStyles.body.copyWith(fontSize: 14),
      bodySmall:      AppTextStyles.muted.copyWith(fontSize: 12),
      labelSmall:     AppTextStyles.mono.copyWith(fontSize: 12),
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),

    cardTheme: CardThemeData(
      color: AppColors.active,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
    ),

    listTileTheme: const ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: AppColors.active,
      textColor: AppColors.primaryText,
      iconColor: AppColors.mutedText,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.active,
      labelStyle: AppTextStyles.muted14,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryText, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryText,
        foregroundColor: AppColors.active,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: AppTextStyles.heading.copyWith(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mutedText,
        textStyle: AppTextStyles.body14,
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sidebarBg,
      foregroundColor: AppColors.primaryText,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}