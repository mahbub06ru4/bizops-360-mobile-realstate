import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../localization/translation_keys.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import 'app_button.dart';

/// Transient bottom messages. Tone picks the accent stripe colour.
enum FeedbackTone { neutral, success, warning, error }

abstract final class AppSnackbar {
  static void show(
    String message, {
    String? title,
    FeedbackTone tone = FeedbackTone.neutral,
  }) {
    final c = _colors;
    final accent = switch (tone) {
      FeedbackTone.neutral => c.brand,
      FeedbackTone.success => c.brand,
      FeedbackTone.warning => c.signal,
      FeedbackTone.error => c.critical,
    };
    Get.snackbar(
      title ?? '',
      message,
      titleText: title == null ? const SizedBox.shrink() : null,
      snackPosition: SnackPosition.BOTTOM,
      margin: EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      leftBarIndicatorColor: accent,
      backgroundColor: c.ink,
      colorText: c.ground,
    );
  }

  static void error(String message, {String? title}) =>
      show(message, title: title, tone: FeedbackTone.error);
}

abstract final class AppDialog {
  /// A yes/no prompt. Resolves to `true` only when the user confirms.
  static Future<bool> confirm({
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
  }) async {
    final c = _colors;
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.brLg),
        title: Text(title),
        content: Text(message),
        actions: [
          AppButton(
            label: cancelLabel ?? Tr.cancel.tr,
            onPressed: () => Get.back<bool>(result: false),
            variant: AppButtonVariant.text,
            expand: false,
          ),
          AppButton(
            label: confirmLabel ?? Tr.ok.tr,
            onPressed: () => Get.back<bool>(result: true),
            expand: false,
          ),
        ],
        actionsPadding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
      ),
      barrierColor: c.ink.withValues(alpha: 0.4),
    );
    return result ?? false;
  }
}

abstract final class AppBottomSheet {
  /// Shows [child] in the app's rounded, drag-handled sheet.
  static Future<T?> show<T>(Widget child, {bool isScrollControlled = true}) {
    final c = _colors;
    return Get.bottomSheet<T>(
      SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.r,
                height: 4.r,
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: c.lineStrong,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
    );
  }
}

AppColors get _colors => Get.context!.colors;
