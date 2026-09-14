import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A hand-rolled shimmer — a highlight sweeping across a muted base — used for
/// skeleton placeholders while a screen's first data loads. No package needed.
class AppShimmer extends StatefulWidget {
  const AppShimmer({required this.child, this.enabled = true, super.key});

  final Widget child;
  final bool enabled;

  /// A single rounded bar, e.g. a line of skeleton text.
  static Widget bar({double? width, double height = 12}) =>
      _ShimmerBox(width: width, height: height);

  /// A square/circle block, e.g. a skeleton avatar.
  static Widget block({required double size, bool circle = false}) =>
      _ShimmerBox(width: size, height: size, circle: circle);

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final c = context.colors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width * (2 * _controller.value - 1);
            return LinearGradient(
              colors: [c.surfaceAlt, c.line, c.surfaceAlt],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(dx),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.dx);

  final double dx;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(dx, 0, 0);
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({this.width, required this.height, this.circle = false});

  final double? width;
  final double height;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      width: width,
      height: height.r,
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: circle ? null : AppRadius.brSm,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
