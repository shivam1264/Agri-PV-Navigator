import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static Brightness currentBrightness = Brightness.light;
  static bool get isDark => currentBrightness == Brightness.dark;

  static ThemeData get lightTheme => getLightTheme();
  static ThemeData get darkTheme => getDarkTheme();

  static ThemeData getLightTheme({bool highContrast = false}) {
    final borderColor = highContrast ? const Color(0xFF000000) : AppColors.border;
    final borderWidth = highContrast ? 2.0 : 1.0;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: highContrast ? Colors.white : AppColors.background,
      cardColor: Colors.white,
      dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      colorScheme: ColorScheme.light(
        primary: highContrast ? const Color(0xFF04542B) : AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primarySurface,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: highContrast ? Colors.black : AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: highContrast ? Colors.black : AppColors.textPrimary),
        titleTextStyle: TextStyle(
          color: highContrast ? Colors.black : AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highContrast ? const Color(0xFF04542B) : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: borderWidth),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      dividerColor: borderColor,
    );
  }

  /// Eye-catchy, ultra-professional luxury obsidian dark theme
  static ThemeData getDarkTheme({bool highContrast = false}) {
    // Obsidian deep carbon palette
    final scaffoldBg = highContrast ? const Color(0xFF000000) : const Color(0xFF090D0B);
    final cardBg = highContrast ? const Color(0xFF0A100C) : const Color(0xFF121815);
    final sheetBg = highContrast ? const Color(0xFF080D0A) : const Color(0xFF141C18);
    final borderColor = highContrast ? const Color(0xFF00E676) : const Color(0xFF202E25);
    final borderWidth = highContrast ? 2.0 : 1.0;

    // Bioluminescent eye-catchy neon emerald
    const neonEmerald = Color(0xFF00E676);
    const darkEmeraldText = Color(0xFF031A0B);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardBg,
      dialogTheme: DialogThemeData(backgroundColor: sheetBg),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: sheetBg,
        surfaceTintColor: Colors.transparent,
      ),
      colorScheme: ColorScheme.dark(
        primary: neonEmerald,
        onPrimary: darkEmeraldText,
        primaryContainer: const Color(0xFF123520),
        onPrimaryContainer: const Color(0xFFB9F6CA),
        secondary: const Color(0xFF10B981),
        onSecondary: Colors.black,
        surface: cardBg,
        onSurface: Colors.white,
        onSurfaceVariant: const Color(0xFF94A3B8),
        error: const Color(0xFFF87171),
        onError: Colors.black,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        titleMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        bodyLarge: const TextStyle(color: Color(0xFFF1F5F9)),
        bodyMedium: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0C130F),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: neonEmerald, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonEmerald,
          foregroundColor: darkEmeraldText,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonEmerald,
          side: const BorderSide(color: neonEmerald, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: neonEmerald,
        inactiveTrackColor: const Color(0xFF1E2F24),
        thumbColor: neonEmerald,
        overlayColor: neonEmerald.withValues(alpha: 0.18),
        trackHeight: 5.0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0A0E0C),
        selectedItemColor: neonEmerald,
        unselectedItemColor: Color(0xFF64748B),
      ),
      dividerColor: borderColor,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? neonEmerald : const Color(0xFF64748B),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? const Color(0xFF123B22) : const Color(0xFF1C2720),
        ),
      ),
    );
  }
}
