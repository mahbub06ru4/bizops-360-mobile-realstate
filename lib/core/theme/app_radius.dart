import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Corner radii from the approved mockup: 8 for fields, 12 for cards/sheets,
/// 16 for large surfaces, fully round for chips and buttons. Scaled via `.r`.
abstract final class AppRadius {
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get pill => 999.r;

  static BorderRadius get brSm => BorderRadius.circular(sm);
  static BorderRadius get brMd => BorderRadius.circular(md);
  static BorderRadius get brLg => BorderRadius.circular(lg);
  static BorderRadius get brPill => BorderRadius.circular(pill);
}

/// Elevation steps. Not scaled — shadow depth is physical, not layout.
abstract final class AppElevation {
  static const double none = 0;
  static const double hairline = 0.5;
  static const double raised = 2;
  static const double overlay = 6;
}
