import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The BizOps 360 mark — a bordered square with a wayfinding-amber trend line,
/// matching the design mockup.
class AppLogo extends StatelessWidget {
  const AppLogo({this.size = 32, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Align keeps the paint box at [size] even inside a stretch parent (which
    // would otherwise scale the drawing to the full parent width).
    return Align(
      alignment: Alignment.centerLeft,
      heightFactor: 1,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          size: Size.square(size),
          painter: _LogoPainter(border: colors.ink, accent: colors.signal),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.border, required this.accent});

  final Color border;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final borderPaint = Paint()
      ..color = border
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.06;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.05, s * 0.05, s * 0.9, s * 0.9),
      Radius.circular(s * 0.22),
    );
    canvas.drawRRect(r, borderPaint);

    final line = Paint()
      ..color = accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(s * 0.25, s * 0.64)
      ..lineTo(s * 0.44, s * 0.34)
      ..lineTo(s * 0.56, s * 0.53)
      ..lineTo(s * 0.66, s * 0.39)
      ..lineTo(s * 0.75, s * 0.55);
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.border != border || old.accent != accent;
}
