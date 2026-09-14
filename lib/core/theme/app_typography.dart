import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type pairing from the design mockup:
///  - Bricolage Grotesque — headings, with a slight signage character
///  - Public Sans — the dense running UI
///  - IBM Plex Mono — every code the desk lives by (PNR, flight no, amounts)
///  - Hind Siliguri — Bangla, applied automatically as a fallback
class AppTypography {
  const AppTypography._();

  static String get _displayFamily =>
      GoogleFonts.bricolageGrotesque().fontFamily!;
  static List<String> get _bengaliFallback => [
    GoogleFonts.hindSiliguri().fontFamily!,
  ];

  /// Monospace style for data (PNR `BQ7K2P`, `BG388`, `৳90,000`).
  static TextStyle mono(
    Color color, {
    double size = 13,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.ibmPlexMono(
      color: color,
      fontSize: size,
      fontWeight: weight,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextTheme textTheme(Color ink, Color muted) {
    final base = GoogleFonts.publicSansTextTheme().apply(
      bodyColor: ink,
      displayColor: ink,
      fontFamilyFallback: _bengaliFallback,
    );

    TextStyle display(
      double size,
      FontWeight weight, {
      double spacing = -0.02,
    }) => TextStyle(
      fontFamily: _displayFamily,
      fontFamilyFallback: _bengaliFallback,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: size * spacing,
      height: 1.08,
      color: ink,
    );

    return base.copyWith(
      displayLarge: display(34, FontWeight.w700),
      displayMedium: display(28, FontWeight.w700),
      displaySmall: display(23, FontWeight.w600),
      headlineMedium: display(20, FontWeight.w600, spacing: -0.015),
      headlineSmall: display(17, FontWeight.w600, spacing: -0.01),
      titleLarge: display(16, FontWeight.w600, spacing: -0.005),
      titleMedium: base.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 15, height: 1.45),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13.5,
        height: 1.45,
        color: muted,
      ),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12, color: muted),
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 13.5,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 10.5,
        letterSpacing: 1.3,
        color: muted,
      ),
    );
  }
}
