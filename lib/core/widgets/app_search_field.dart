import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A debounced search box: a leading search icon, a trailing clear (×) button
/// once there's text, and [onChanged] fired [debounce] after the user stops
/// typing (not on every keystroke) — the list-filter screens (Customers,
/// Travellers, …) all want this shape.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.hint,
    this.onChanged,
    this.debounce = const Duration(milliseconds: 300),
    super.key,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final Duration debounce;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // toggle the clear button
    _debounce?.cancel();
    _debounce = Timer(
      widget.debounce,
      () => widget.onChanged?.call(value.trim()),
    );
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    widget.onChanged?.call('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(Icons.search, size: 20.r),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: _clear,
                icon: Icon(Icons.close, size: 18.r),
              ),
      ),
    );
  }
}
