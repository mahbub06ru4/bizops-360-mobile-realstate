import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../localization/translation_keys.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Placeholder body for a route whose UI slice hasn't landed yet.
class ComingSoon extends StatelessWidget {
  const ComingSoon({this.label, super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_outlined, size: 40.r, color: c.lineStrong),
          SizedBox(height: AppSpacing.md),
          if (label != null) Text(label!, style: text.titleMedium),
          SizedBox(height: AppSpacing.xxs),
          Text(Tr.comingSoon.tr, style: text.bodyMedium),
        ],
      ),
    );
  }
}
