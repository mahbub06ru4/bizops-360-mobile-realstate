import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The one spacing scale for the app. Every gap, pad and inset comes from here
/// so rhythm stays consistent and responsive — values are scaled from the
/// 375 × 812 design frame via `flutter_screenutil`'s `.r`.
///
/// Widgets read `AppSpacing.md`, never a literal `12`.
abstract final class AppSpacing {
  static double get xxs => 2.r;
  static double get xs => 4.r;
  static double get sm => 8.r;
  static double get md => 12.r;
  static double get lg => 16.r;
  static double get xl => 24.r;
  static double get xxl => 32.r;
  static double get xxxl => 48.r;

  /// Standard screen edge padding (horizontal + top/bottom on scroll views).
  static EdgeInsets get screen =>
      EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  /// Inset for a card / sheet body.
  static EdgeInsets get card => EdgeInsets.all(md);
}

/// Fixed vertical / horizontal gaps for `Column` / `Row` children.
abstract final class Gap {
  static Widget get xs => SizedBox(width: AppSpacing.xs, height: AppSpacing.xs);
  static Widget get sm => SizedBox(width: AppSpacing.sm, height: AppSpacing.sm);
  static Widget get md => SizedBox(width: AppSpacing.md, height: AppSpacing.md);
  static Widget get lg => SizedBox(width: AppSpacing.lg, height: AppSpacing.lg);
  static Widget get xl => SizedBox(width: AppSpacing.xl, height: AppSpacing.xl);
}
