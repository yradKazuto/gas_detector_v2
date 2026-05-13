import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF161616);
  static const surfaceAlt = Color(0xFF1E1E1E);
  static const border = Color(0xFF2A2A2A);

  static const safe = Color(0xFF4ADE80);
  static const safeBackground = Color(0xFF0F1F14);
  static const safeBorder = Color(0xFF1A3D22);

  static const warning = Color(0xFFFACC15);
  static const warningBackground = Color(0xFF1F1A0A);
  static const warningBorder = Color(0xFF3D3010);

  static const danger = Color(0xFFF87171);
  static const dangerBackground = Color(0xFF1F0C0C);
  static const dangerBorder = Color(0xFF4A1515);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
  static const textMuted = Color(0xFF555555);

  static const barSafe = Color(0xFF1A3D22);
  static const barWarning = Color(0xFF3D3010);
  static const barDanger = Color(0xFF4A1515);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.surface,
          primary: AppColors.safe,
          error: AppColors.danger,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.textPrimary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerColor: AppColors.border,
      );
}

class AppConstants {
  static const int defaultWarningThreshold = 1500;
  static const int defaultDangerThreshold = 2000;
  static const int maxAdcValue = 4095;
  static const String defaultIp = '192.168.1.100';
  static const int defaultPort = 81;
  static const int defaultIntervalMs = 500;
  static const int historyMaxPoints = 60;
}
