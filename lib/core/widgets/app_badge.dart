import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// A small count badge, typically stacked on an icon (unread notifications).
/// Renders nothing when [count] is 0; caps the label at "9+" past [max].
class AppBadge extends StatelessWidget {
  const AppBadge({required this.count, this.child, this.max = 9, super.key});

  final int count;
  final Widget? child;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (count <= 0) return child ?? const SizedBox.shrink();

    final label = count > max ? '$max+' : '$count';
    final dot = Container(
      padding: EdgeInsets.symmetric(horizontal: 5.r, vertical: 1.r),
      constraints: BoxConstraints(minWidth: 16.r, minHeight: 16.r),
      decoration: BoxDecoration(
        color: c.critical,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: c.surface, width: 1.5),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );

    if (child == null) return dot;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(right: -4.r, top: -4.r, child: dot),
      ],
    );
  }
}
