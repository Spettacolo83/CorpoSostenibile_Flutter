import 'package:flutter/material.dart';

/// Palette colori "Biohacking Tech" - Design Futuristico
/// Per Corpo Sostenibile - Tech Company di Salute e Benessere
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════
  //                    PRIMARY - Verde Cyber-Teal
  // ═══════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF00D9A6);           // Verde-Teal Elettrico
  static const Color primaryLight = Color(0xFF33E3BC);      // Glow verde chiaro
  static const Color primaryMedium = Color(0xFF00C897);     // Verde medio
  static const Color primaryDark = Color(0xFF00B388);       // Verde intenso
  static const Color primarySurface = Color(0xFF0A2922);    // Verde profondo (dark mode)
  static const Color splashBackground = Color(0xFF143029);  // Verde scuro originale splash

  // ═══════════════════════════════════════════════════════════════
  //                    ACCENT - Cyan Tech
  // ═══════════════════════════════════════════════════════════════
  static const Color accent = Color(0xFF00C8FF);            // Cyan Brillante
  static const Color accentLight = Color(0xFF66DBFF);       // Cyan chiaro
  static const Color accentDark = Color(0xFF00A3D9);        // Cyan scuro

  // ═══════════════════════════════════════════════════════════════
  //                    SECONDARY - Viola Futuristico
  // ═══════════════════════════════════════════════════════════════
  static const Color secondary = Color(0xFF8B5CF6);         // Deep Violet
  static const Color secondaryLight = Color(0xFFA78BFA);    // Viola chiaro
  static const Color secondaryDark = Color(0xFF7C3AED);     // Viola intenso

  // ═══════════════════════════════════════════════════════════════
  //                    NEON COLORS - Per grafici e highlights
  // ═══════════════════════════════════════════════════════════════
  static const Color neonOrange = Color(0xFFFF6B35);        // Arancione Neon acceso
  static const Color neonPink = Color(0xFFFF2D92);          // Rosa Neon
  static const Color neonPurple = Color(0xFFBF5AF2);        // Viola Neon
  static const Color neonBlue = Color(0xFF00D4FF);          // Blu Neon
  static const Color neonYellow = Color(0xFFFFE135);        // Giallo Neon
  static const Color neonRed = Color(0xFFFF3B5C);           // Rosso Neon

  // ═══════════════════════════════════════════════════════════════
  //                    LIGHT MODE - Superfici e Sfondi
  // ═══════════════════════════════════════════════════════════════
  static const Color background = Color(0xFFF8FAFB);        // Bianco-grigio freddo
  static const Color surface = Color(0xFFFFFFFF);           // Bianco puro
  static const Color surfaceVariant = Color(0xFFF0F3F5);    // Grigio chiarissimo
  static const Color surfaceElevated = Color(0xFFFFFFFF);   // Superficie elevata

  // ═══════════════════════════════════════════════════════════════
  //                    LIGHT MODE - Testi
  // ═══════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF0F172A);       // Blu-nero profondo
  static const Color textSecondary = Color(0xFF64748B);     // Grigio ardesia
  static const Color textHint = Color(0xFF94A3B8);          // Grigio hint
  static const Color textOnPrimary = Color(0xFFFFFFFF);     // Bianco su primary
  static const Color textOnSecondary = Color(0xFFFFFFFF);   // Bianco su secondary

  // ═══════════════════════════════════════════════════════════════
  //                    LIGHT MODE - Divisori e Bordi
  // ═══════════════════════════════════════════════════════════════
  static const Color divider = Color(0xFFE2E8F0);           // Divisore chiaro
  static const Color border = Color(0xFFCBD5E1);            // Bordo grigio

  // ═══════════════════════════════════════════════════════════════
  //                    STATI - Colori accesi tech
  // ═══════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF00FF88);           // Verde Neon
  static const Color warning = Color(0xFFFF6B35);           // Arancione Neon (più acceso!)
  static const Color error = Color(0xFFFF3B5C);             // Rosso Neon
  static const Color info = Color(0xFF00D4FF);              // Blu Neon

  // ═══════════════════════════════════════════════════════════════
  //                    DARK MODE - Superfici e Sfondi
  // ═══════════════════════════════════════════════════════════════
  static const Color backgroundDark = Color(0xFF0C1015);    // Nero con hint blu
  static const Color surfaceDark = Color(0xFF141A21);       // Superficie rialzata
  static const Color surfaceVariantDark = Color(0xFF1C242D); // Variante più chiara
  static const Color surfaceElevatedDark = Color(0xFF242D38); // Superficie elevata

  // ═══════════════════════════════════════════════════════════════
  //                    DARK MODE - Testi
  // ═══════════════════════════════════════════════════════════════
  static const Color textPrimaryDark = Color(0xFFF1F5F9);   // Bianco-grigio
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Grigio chiaro
  static const Color textHintDark = Color(0xFF64748B);      // Grigio hint

  // ═══════════════════════════════════════════════════════════════
  //                    DARK MODE - Divisori e Bordi
  // ═══════════════════════════════════════════════════════════════
  static const Color dividerDark = Color(0xFF1E293B);       // Divisore scuro
  static const Color borderDark = Color(0xFF334155);        // Bordo scuro

  // ═══════════════════════════════════════════════════════════════
  //                    GRADIENTI TECH (per uso in widget)
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

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonPink, neonPurple, neonBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmNeonGradient = LinearGradient(
    colors: [neonOrange, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [surfaceDark, backgroundDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
