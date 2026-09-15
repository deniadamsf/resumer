import 'package:flutter/material.dart';

/// Palet Warna Resmi: "The Bespoke Executive Palette" (Quiet Luxury)
/// Mematuhi rancangan pada rangkuman_konsultasi_aplikasi.md & GEMINI.md
class AppColors {
  // Warna Utama (Brand, Wibawa & Tombol Utama)
  static const Color midnightNavy = Color(0xFF0B132B);
  static const Color mutedSteelSlate = Color(0xFF1C2541);
  static const Color accentSteel = Color(0xFF3A506B);
  static const Color subtleSlateTint = Color(0xFFF1F5F9);

  // Aksen Status & Skor ATS (Matte & Sophisticated Feedback)
  static const Color forestPine = Color(0xFF065F46); // Skor 85 - 100
  static const Color forestPineLight = Color(0xFF047857);
  static const Color antiqueBronze = Color(0xFF92400E); // Skor 60 - 84 & Rewarded Ads
  static const Color antiqueBronzeLight = Color(0xFFB45309);
  static const Color crimsonBordeaux = Color(0xFF881337); // Skor < 60
  static const Color crimsonBordeauxLight = Color(0xFF991B1B);

  // Warna Netral & Kanvas Latar Belakang (Paper-Feel)
  static const Color oysterCanvas = Color(0xFFF8F9FA);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color borderHairline = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0A0F1D);
  static const Color textSecondary = Color(0xFF64748B);

  // Dynamic ATS Color Resolver
  static Color getScoreColor(int score) {
    if (score >= 85) return forestPine;
    if (score >= 60) return antiqueBronze;
    return crimsonBordeaux;
  }
}
