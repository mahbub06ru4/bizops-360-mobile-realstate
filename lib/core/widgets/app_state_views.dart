import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../localization/translation_keys.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

/// Centred spinner for a first load. Give it [label] to caption long waits.
class AppLoader extends StatelessWidget {
  const AppLoader({this.label, super.key});

  final String? label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24.r,
            height: 24.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          if (label != null) ...[
            SizedBox(height: AppSpacing.md),
            Text(label!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

/// Nothing to show — not a failure (an empty list, no results, a clear inbox).
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String? title;
  final String? message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: icon,
      title: title ?? Tr.emptyTitle.tr,
      message: message,
      action: action,
    );
  }
}

/// A load failed — shows [Tr.errorTitle] (or [message]) and a retry button.
class AppErrorState extends StatelessWidget {
  const AppErrorState({this.title, this.message, this.onRetry, super.key});

  final String? title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: Icons.error_outline,
      title: title ?? Tr.errorTitle.tr,
      message: message,
      action: onRetry == null ? null : _RetryButton(onRetry!),
    );
  }
}

/// No connectivity — a specialised [AppErrorState].
class AppNetworkError extends StatelessWidget {
  const AppNetworkError({this.onRetry, super.key});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateScaffold(
      icon: Icons.wifi_off_outlined,
      title: Tr.offlineTitle.tr,
      message: Tr.offlineBody.tr,
      action: onRetry == null ? null : _RetryButton(onRetry!),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton(this.onRetry);

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: Tr.retry.tr,
      onPressed: onRetry,
      variant: AppButtonVariant.secondary,
      icon: Icons.refresh,
      expand: false,
    );
  }
}

class _StateScaffold extends StatelessWidget {
  const _StateScaffold({
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40.r, color: c.inkFaint),
            SizedBox(height: AppSpacing.md),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                message!,
                style: text.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[SizedBox(height: AppSpacing.lg), action!],
          ],
        ),
      ),
    );
  }
}
