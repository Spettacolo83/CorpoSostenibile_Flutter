import 'package:flutter/material.dart';

/// Palette colori "Modern Fitness"
/// Stile moderno, futuristico con glassmorphism e gamification
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  //                    PRIMARY - Coral/Salmon
  // ═══════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFFFF6B6B);           // Coral principale
  static const Color primaryLight = Color(0xFFFF8E8E);      // Coral chiaro
  static const Color primaryMedium = Color(0xFFFA5252);     // Coral medio
  static const Color primaryDark = Color(0xFFE64545);       // Coral scuro
  static const Color primarySurface = Color(0xFFFFF5F5);    // Coral surface (per card)

  // ═══════════════════════════════════════════════════════════════
  //                    SECONDARY - Soft Teal
  // ═══════════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFF10B981);         // Teal morbido
  static const Color secondaryLight = Color(0xFF34D399);    // Teal chiaro
  static const Color secondaryDark = Color(0xFF059669);     // Teal scuro

  // ═══════════════════════════════════════════════════════════════
  //                    ACCENT - Warm Orange
  // ═══════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFFF97316);            // Arancione caldo
  static const Color accentLight = Color(0xFFFB923C);       // Arancione chiaro
  static const Color accentDark = Color(0xFFEA580C);        // Arancione scuro

  // ═══════════════════════════════════════════════════════════════
  //                    SUPERFICI E SFONDI
  // ═══════════════════════════════════════════════════════════════
  static const Color background = Color(0xFFFAFAF9);        // Bianco caldo
  static const Color surface = Color(0xFFFFFFFF);           // Bianco puro
  static const Color surfaceVariant = Color(0xFFF5F5F4);    // Grigio caldo chiaro
  static const Color surfaceElevated = Color(0xFFFFFFFF);   // Superficie elevata

  // ═══════════════════════════════════════════════════════════════
  //                    TESTI
  // ═══════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF1F2937);       // Grigio scuro caldo
  static const Color textSecondary = Color(0xFF6B7280);     // Grigio medio
  static const Color textHint = Color(0xFF9CA3AF);          // Grigio chiaro
  static const Color textOnPrimary = Color(0xFFFFFFFF);     // Bianco su primary
  static const Color textOnSecondary = Color(0xFFFFFFFF);   // Bianco su secondary

  // ═══════════════════════════════════════════════════════════════
  //                    DIVISORI E BORDI
  // ═══════════════════════════════════════════════════════════════
  static const Color divider = Color(0xFFE5E7EB);           // Divisore grigio
  static const Color border = Color(0xFFD1D5DB);            // Bordo grigio

  // ═══════════════════════════════════════════════════════════════
  //                    STATI
  // ═══════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF10B981);           // Verde successo
  static const Color warning = Color(0xFFF59E0B);           // Ambra warning
  static const Color error = Color(0xFFEF4444);             // Rosso errore
  static const Color info = Color(0xFF3B82F6);              // Blu info

  // ═══════════════════════════════════════════════════════════════
  //                    COLORI GRAFICI E CATEGORIE
  // ═══════════════════════════════════════════════════════════════
  static const Color chartPink = Color(0xFFEC4899);         // Rosa per grafici
  static const Color chartPurple = Color(0xFF8B5CF6);       // Viola per grafici
  static const Color chartBlue = Color(0xFF3B82F6);         // Blu per grafici
  static const Color chartTeal = Color(0xFF14B8A6);         // Teal per grafici
  static const Color chartOrange = Color(0xFFF97316);       // Arancione per grafici
  static const Color chartYellow = Color(0xFFEAB308);       // Giallo per grafici

  // ═══════════════════════════════════════════════════════════════
  //                    GRADIENTI
  // ═══════════════════════════════════════════════════════════════
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientVertical = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient freshGradient = LinearGradient(
    colors: [secondary, Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softGradient = LinearGradient(
    colors: [Color(0xFFFFF5F5), Color(0xFFFAFAF9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1F2937), Color(0xFF374151)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [secondary, Color(0xFF14B8A6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════════════════════
  //                    GLASSMORPHISM
  // ═══════════════════════════════════════════════════════════════
  static Color get glassWhite => Colors.white.withValues(alpha: 0.15);
  static Color get glassWhiteLight => Colors.white.withValues(alpha: 0.25);
  static Color get glassBorder => Colors.white.withValues(alpha: 0.2);
  static Color get glassShadow => Colors.black.withValues(alpha: 0.1);
  static Color get glassOverlay => Colors.black.withValues(alpha: 0.3);

  // ═══════════════════════════════════════════════════════════════
  //                    ACHIEVEMENT TIERS
  // ═══════════════════════════════════════════════════════════════
  static const Color bronze = Color(0xFFCD7F32);
  static const Color silver = Color(0xFFC0C0C0);
  static const Color gold = Color(0xFFFFD700);
  static const Color platinum = Color(0xFFE5E4E2);

  // ═══════════════════════════════════════════════════════════════
  //                    RING PROGRESS COLORS
  // ═══════════════════════════════════════════════════════════════
  static const Color ringCalories = Color(0xFFFF6B6B);  // Coral
  static const Color ringActivity = Color(0xFF10B981);  // Teal
  static const Color ringWater = Color(0xFF3B82F6);     // Blue
  static const Color ringSleep = Color(0xFF8B5CF6);     // Purple
}
