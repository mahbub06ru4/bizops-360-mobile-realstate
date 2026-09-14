import 'package:flutter/material.dart';

import '../state/async_value.dart';
import 'app_state_views.dart';

/// Renders an [AsyncValue] with the app's standard loading / error / empty /
/// data treatment. Wrap in `Obx` at the call site when [value] is reactive.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.value,
    required this.data,
    this.isEmpty,
    this.empty,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;

  /// When true for the loaded value, [empty] (or a default) is shown instead.
  final bool Function(T value)? isEmpty;
  final Widget? empty;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const AppLoader(),
      error: (f) => AppErrorState(message: f.message, onRetry: onRetry),
      data: (v) {
        if (isEmpty?.call(v) ?? false) {
          return empty ?? const AppEmptyState();
        }
        return data(v);
      },
    );
  }
}
