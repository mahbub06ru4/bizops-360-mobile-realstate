import 'package:flutter/material.dart';

/// One item in an [AppDropdown].
class AppDropdownItem<T> {
  const AppDropdownItem(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// The one dropdown — a labeled [DropdownButtonFormField] matching the app's
/// field decoration, so it sits next to an [AppTextField] without looking like
/// a different widget system.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final List<AppDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, errorText: errorText),
      items: [
        for (final item in items)
          DropdownMenuItem<T>(
            value: item.value,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(item.label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
