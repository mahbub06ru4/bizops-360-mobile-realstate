import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Visual weight of an [AppButton].
enum AppButtonVariant { primary, secondary, text }

/// The one button. `primary` is the wayfinding-amber call to action,
/// `secondary` an outlined action, `text` a low-emphasis link.
///
/// Handles its own busy state: pass [loading] and the label is swapped for a
/// spinner and taps are ignored.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool loading;

  /// Stretch to the full available width (the default for form actions).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final effectiveOnPressed = loading ? null : onPressed;

    final child = loading
        ? SizedBox(
            width: 18.r,
            height: 18.r,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == AppButtonVariant.primary
                  ? c.signalInk
                  : c.brand,
            ),
          )
        : _label();

    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };

    if (!expand || variant == AppButtonVariant.text) return button;
    return SizedBox(width: double.infinity, child: button);
  }

  Widget _label() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18.r),
        SizedBox(width: 8.r),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
