import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Configurazione del tema "Biohacking Tech".
/// Design futuristico con forme squadrate e colori cyber.
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════
  //                    BORDER RADIUS - Tech Style (Squadrato)
  // ═══════════════════════════════════════════════════════════════
  static const double radiusNone = 0.0;    // Componenti squadrati
  static const double radiusSmall = 4.0;   // chips, badges
  static const double radiusMedium = 6.0;  // buttons, inputs
  static const double radiusLarge = 8.0;   // cards
  static const double radiusXL = 12.0;     // modals, sheets

  // ═══════════════════════════════════════════════════════════════
  //                    BLUR APPBAR - Altezza safe area
  // ═══════════════════════════════════════════════════════════════
  static const double appBarHeight = 56.0;

  /// Tema chiaro
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentLight,
        surface: AppColors.surface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        error: AppColors.error,
        onPrimary: AppColors.textOnPrimary,
        onSecondary: AppColors.textOnSecondary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textOnPrimary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: _buildAppBarTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.light),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
      cardTheme: _buildCardTheme(Brightness.light),
      bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.light),
      navigationBarTheme: _buildNavigationBarTheme(Brightness.light),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      chipTheme: _buildChipTheme(Brightness.light),
      floatingActionButtonTheme: _buildFabTheme(Brightness.light),
      dialogTheme: _buildDialogTheme(Brightness.light),
      bottomSheetTheme: _buildBottomSheetTheme(Brightness.light),
      snackBarTheme: _buildSnackBarTheme(Brightness.light),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceVariant,
      ),
      listTileTheme: _buildListTileTheme(Brightness.light),
    );
  }

  /// Tema scuro
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primarySurface,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accentDark,
        surface: AppColors.surfaceDark,
        surfaceContainerHighest: AppColors.surfaceVariantDark,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textPrimaryDark,
        onSurface: AppColors.textPrimaryDark,
        onError: AppColors.textOnPrimary,
        outline: AppColors.borderDark,
        outlineVariant: AppColors.dividerDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _buildOutlinedButtonTheme(Brightness.dark),
      textButtonTheme: _buildTextButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
      cardTheme: _buildCardTheme(Brightness.dark),
      bottomNavigationBarTheme: _buildBottomNavTheme(Brightness.dark),
      navigationBarTheme: _buildNavigationBarTheme(Brightness.dark),
      dividerTheme: const DividerThemeData(color: AppColors.dividerDark, thickness: 1),
      chipTheme: _buildChipTheme(Brightness.dark),
      floatingActionButtonTheme: _buildFabTheme(Brightness.dark),
      dialogTheme: _buildDialogTheme(Brightness.dark),
      bottomSheetTheme: _buildBottomSheetTheme(Brightness.dark),
      snackBarTheme: _buildSnackBarTheme(Brightness.dark),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primary.withValues(alpha: 0.2),
      ),
      listTileTheme: _buildListTileTheme(Brightness.dark),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    NAVIGATION BAR - Tech Style
  // ═══════════════════════════════════════════════════════════════
  static NavigationBarThemeData _buildNavigationBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return NavigationBarThemeData(
      height: 72,
      elevation: 0,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.primary, size: 24);
        }
        return IconThemeData(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          );
        }
        return GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    TEXT THEME - Modern Typography
  // ═══════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? AppColors.textPrimary
        : AppColors.textPrimaryDark;

    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.25,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.light
            ? AppColors.textSecondary
            : AppColors.textSecondaryDark,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: brightness == Brightness.light
            ? AppColors.textSecondary
            : AppColors.textSecondaryDark,
        letterSpacing: 0.5,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    APP BAR - Trasparente (blur applicato nel widget)
  // ═══════════════════════════════════════════════════════════════
  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      iconTheme: IconThemeData(
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        size: 24,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    ELEVATED BUTTON - Tech Style
  // ═══════════════════════════════════════════════════════════════
  static ElevatedButtonThemeData _buildElevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        disabledForegroundColor: AppColors.textPrimary.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    OUTLINED BUTTON - Tech Border Style
  // ═══════════════════════════════════════════════════════════════
  static OutlinedButtonThemeData _buildOutlinedButtonTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    TEXT BUTTON
  // ═══════════════════════════════════════════════════════════════
  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        textStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    INPUT DECORATION - Tech Fields
  // ═══════════════════════════════════════════════════════════════
  static InputDecorationTheme _buildInputDecorationTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final fillColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: GoogleFonts.poppins(
        color: isDark ? AppColors.textHintDark : AppColors.textHint,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.poppins(
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        fontSize: 14,
      ),
      prefixIconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      suffixIconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    CARD - Tech Surface
  // ═══════════════════════════════════════════════════════════════
  static CardTheme _buildCardTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return CardTheme(
      elevation: 0,
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.divider,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    BOTTOM NAV - Legacy Support
  // ═══════════════════════════════════════════════════════════════
  static BottomNavigationBarThemeData _buildBottomNavTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    CHIP - Tech Tags
  // ═══════════════════════════════════════════════════════════════
  static ChipThemeData _buildChipTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ChipThemeData(
      backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      disabledColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
      labelStyle: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSmall),
        side: BorderSide.none,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    FAB - Floating Action Button
  // ═══════════════════════════════════════════════════════════════
  static FloatingActionButtonThemeData _buildFabTheme(Brightness brightness) {
    return FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    DIALOG - Tech Modal
  // ═══════════════════════════════════════════════════════════════
  static DialogTheme _buildDialogTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return DialogTheme(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.divider,
          width: 1,
        ),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    BOTTOM SHEET - Tech Panel
  // ═══════════════════════════════════════════════════════════════
  static BottomSheetThemeData _buildBottomSheetTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return BottomSheetThemeData(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXL)),
      ),
      dragHandleColor: isDark ? AppColors.borderDark : AppColors.border,
      dragHandleSize: const Size(40, 4),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    SNACKBAR - Tech Notification
  // ═══════════════════════════════════════════════════════════════
  static SnackBarThemeData _buildSnackBarTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return SnackBarThemeData(
      backgroundColor: isDark ? AppColors.surfaceElevatedDark : AppColors.textPrimary,
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: isDark ? AppColors.textPrimaryDark : AppColors.surface,
      ),
      actionTextColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      elevation: 0,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //                    LIST TILE - Tech Row
  // ═══════════════════════════════════════════════════════════════
  static ListTileThemeData _buildListTileTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
      ),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
      subtitleTextStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
      iconColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
    );
  }
}
