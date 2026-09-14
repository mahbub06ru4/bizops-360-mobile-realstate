import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// A person's avatar: initials on the brand-soft ground, or [imageUrl] when
/// there is one. [size] is the diameter in design pixels.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.name,
    this.imageUrl,
    this.size = 40,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final double size;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    String head(String s) =>
        String.fromCharCodes(s.runes.take(1)).toUpperCase();
    if (parts.length == 1) return head(parts.first);
    return head(parts.first) + head(parts.last);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final diameter = size.r;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: diameter / 2,
        backgroundColor: c.brandSoft,
        foregroundImage: NetworkImage(imageUrl!),
        onForegroundImageError: (_, _) {},
        child: Text(_initials, style: _textStyle(context)),
      );
    }

    return CircleAvatar(
      radius: diameter / 2,
      backgroundColor: c.brandSoft,
      child: Text(_initials, style: _textStyle(context)),
    );
  }

  TextStyle? _textStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .titleMedium
      ?.copyWith(color: context.colors.brandInk, fontSize: (size * 0.36).sp);
}
