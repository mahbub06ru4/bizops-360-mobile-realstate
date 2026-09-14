import 'package:flutter/material.dart';

/// The BizOps 360 palette — "hangar green" ink, a cool terminal-grey ground,
/// and one wayfinding amber (`signal`) that means *this needs you*. Semantic
/// colours (`success` / `signal` / `critical` / `info`) are held separate from
/// the brand accent.
///
/// Exposed as a [ThemeExtension] so widgets read tokens by name:
/// `context.colors.signal`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ground,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.line,
    required this.lineStrong,
    required this.brand,
    required this.brandInk,
    required this.brandSoft,
    required this.signal,
    required this.signalInk,
    required this.signalSoft,
    required this.critical,
    required this.criticalInk,
    required this.criticalSoft,
    required this.info,
    required this.infoInk,
    required this.infoSoft,
    required this.onBrand,
  });

  final Color ground;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color line;
  final Color lineStrong;
  final Color brand;
  final Color brandInk;
  final Color brandSoft;
  final Color signal;
  final Color signalInk;
  final Color signalSoft;
  final Color critical;
  final Color criticalInk;
  final Color criticalSoft;
  final Color info;
  final Color infoInk;
  final Color infoSoft;
  final Color onBrand;

  Color get success => brand;
  Color get successInk => brandInk;
  Color get successSoft => brandSoft;

  static const AppColors light = AppColors(
    ground: Color(0xFFE7EBE6),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF1EC),
    ink: Color(0xFF14261F),
    inkMuted: Color(0xFF46574F),
    inkFaint: Color(0xFF7B8880),
    line: Color(0xFFD3DAD1),
    lineStrong: Color(0xFFC1CABD),
    brand: Color(0xFF1C6B54),
    brandInk: Color(0xFF0D3A2C),
    brandSoft: Color(0xFFDFEEE7),
    signal: Color(0xFFD9962F),
    signalInk: Color(0xFF7C5413),
    signalSoft: Color(0xFFF6E6C9),
    critical: Color(0xFFB23A2E),
    criticalInk: Color(0xFF7C261E),
    criticalSoft: Color(0xFFF2DCD8),
    info: Color(0xFF2F6D8B),
    infoInk: Color(0xFF1C4658),
    infoSoft: Color(0xFFD8E6EC),
    onBrand: Color(0xFFF2F6F1),
  );

  static const AppColors dark = AppColors(
    ground: Color(0xFF0D1712),
    surface: Color(0xFF16211B),
    surfaceAlt: Color(0xFF1D2A23),
    ink: Color(0xFFE4E9E2),
    inkMuted: Color(0xFFA7B3AA),
    inkFaint: Color(0xFF75837A),
    line: Color(0xFF2A3830),
    lineStrong: Color(0xFF35453B),
    brand: Color(0xFF56AB8C),
    brandInk: Color(0xFF9ED6C1),
    brandSoft: Color(0xFF16342A),
    signal: Color(0xFFE2A548),
    signalInk: Color(0xFFF1CD8D),
    signalSoft: Color(0xFF3A2C14),
    critical: Color(0xFFD9695C),
    criticalInk: Color(0xFFEAA9A1),
    criticalSoft: Color(0xFF38211D),
    info: Color(0xFF6FB0CE),
    infoInk: Color(0xFFA9D2E3),
    infoSoft: Color(0xFF1A2F38),
    onBrand: Color(0xFF0D1712),
  );

  @override
  AppColors copyWith({
    Color? ground,
    Color? surface,
    Color? surfaceAlt,
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? line,
    Color? lineStrong,
    Color? brand,
    Color? brandInk,
    Color? brandSoft,
    Color? signal,
    Color? signalInk,
    Color? signalSoft,
    Color? critical,
    Color? criticalInk,
    Color? criticalSoft,
    Color? info,
    Color? infoInk,
    Color? infoSoft,
    Color? onBrand,
  }) {
    return AppColors(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      brand: brand ?? this.brand,
      brandInk: brandInk ?? this.brandInk,
      brandSoft: brandSoft ?? this.brandSoft,
      signal: signal ?? this.signal,
      signalInk: signalInk ?? this.signalInk,
      signalSoft: signalSoft ?? this.signalSoft,
      critical: critical ?? this.critical,
      criticalInk: criticalInk ?? this.criticalInk,
      criticalSoft: criticalSoft ?? this.criticalSoft,
      info: info ?? this.info,
      infoInk: infoInk ?? this.infoInk,
      infoSoft: infoSoft ?? this.infoSoft,
      onBrand: onBrand ?? this.onBrand,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      ground: Color.lerp(ground, other.ground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandInk: Color.lerp(brandInk, other.brandInk, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      signal: Color.lerp(signal, other.signal, t)!,
      signalInk: Color.lerp(signalInk, other.signalInk, t)!,
      signalSoft: Color.lerp(signalSoft, other.signalSoft, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      criticalInk: Color.lerp(criticalInk, other.criticalInk, t)!,
      criticalSoft: Color.lerp(criticalSoft, other.criticalSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoInk: Color.lerp(infoInk, other.infoInk, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      onBrand: Color.lerp(onBrand, other.onBrand, t)!,
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
