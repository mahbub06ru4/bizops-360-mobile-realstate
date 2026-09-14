import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Semantic tone for a chip. Maps to the `*Soft` / `*Ink` colour pairs.
enum ChipTone { brand, signal, critical, info, neutral }

/// Compact status chip. State reads at a glance from tone + an optional dot,
/// per the design mockup (visa stages, booking status, "due" / "late").
class AppStatusChip extends StatelessWidget {
  const AppStatusChip(
    this.label, {
    this.tone = ChipTone.neutral,
    this.dot = true,
    super.key,
  });

  final String label;
  final ChipTone tone;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final ({Color bg, Color fg}) palette = switch (tone) {
      ChipTone.brand => (bg: c.brandSoft, fg: c.brandInk),
      ChipTone.signal => (bg: c.signalSoft, fg: c.signalInk),
      ChipTone.critical => (bg: c.criticalSoft, fg: c.criticalInk),
      ChipTone.info => (bg: c.infoSoft, fg: c.infoInk),
      ChipTone.neutral => (bg: c.surfaceAlt, fg: c.inkMuted),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: AppRadius.brPill,
        border: tone == ChipTone.neutral ? Border.all(color: c.line) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(
              width: 6.r,
              height: 6.r,
              decoration: BoxDecoration(
                color: palette.fg,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: palette.fg,
              fontWeight: FontWeight.w600,
              fontSize: 11.5.sp,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
