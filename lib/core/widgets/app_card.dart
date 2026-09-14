import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// A plain surface card matching the mockup — 12px radius, hairline border,
/// no shadow. Not everything is a card; use it for a genuine grouping.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final content = Container(
      padding: padding ?? AppSpacing.card,
      decoration: BoxDecoration(
        color: color ?? c.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: borderColor ?? c.line),
      ),
      child: child,
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, borderRadius: AppRadius.brMd, child: content);
  }
}

/// Uppercase tracked mini-label used above lists ("FOLLOW-UPS", "TODAY").
class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel(this.text, {this.trailing, super.key});

  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.xxs,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          Expanded(child: Text(text.toUpperCase(), style: style)),
          if (trailing != null) Text(trailing!, style: style),
        ],
      ),
    );
  }
}
