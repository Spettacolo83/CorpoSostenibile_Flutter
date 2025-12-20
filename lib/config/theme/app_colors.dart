import 'package:flutter/material.dart';

/// Palette colori ufficiale Corpo Sostenibile.
/// Basata sui colori del brand aziendale.
class AppColors {
  AppColors._();

  // Colori primari - Verde brand (dal logo)
  static const Color primary = Color(0xFF82B255);       // Verde principale logo
  static const Color primaryLight = Color(0xFFBCE587);  // Verde chiaro logo
  static const Color primaryMedium = Color(0xFF8FBF64); // Verde medio logo
  static const Color primaryDark = Color(0xFF143029);   // Verde scuro brand

  // Colore secondario - Verde scuro per contrasto
  static const Color secondary = Color(0xFF143029);
  static const Color secondaryLight = Color(0xFF1E4A3D);
  static const Color secondaryDark = Color(0xFF0A1814);

  // Colori di accento - Sfumature del verde brand
  static const Color accent = Color(0xFF8FBF64);
  static const Color accentLight = Color(0xFFBCE587);
  static const Color accentDark = Color(0xFF6A9A45);

  // Colori neutri - Sfondo brand
  static const Color background = Color(0xFFF8F9F5);    // Sfondo chiaro brand
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2EC);

  // Testi
  static const Color textPrimary = Color(0xFF143029);   // Verde scuro per testi
  static const Color textSecondary = Color(0xFF5A6B66);
  static const Color textHint = Color(0xFF8A9A95);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);

  // Stati
  static const Color success = Color(0xFF82B255);       // Verde brand
  static const Color warning = Color(0xFFE5A842);
  static const Color error = Color(0xFFD64545);
  static const Color info = Color(0xFF4A90A4);

  // Divisori e bordi
  static const Color divider = Color(0xFFE5E8E0);
  static const Color border = Color(0xFFCDD4C8);

  // Dark mode
  static const Color backgroundDark = Color(0xFF0F1F1A);
  static const Color surfaceDark = Color(0xFF143029);
  static const Color surfaceVariantDark = Color(0xFF1E4A3D);
  static const Color textPrimaryDark = Color(0xFFF8F9F5);
  static const Color textSecondaryDark = Color(0xFFBCE587);
}
