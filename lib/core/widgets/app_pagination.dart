import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../localization/translation_keys.dart';
import '../paging/paging_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// List footer for an infinite-scroll list backed by a [PagingController]:
/// a spinner while the next page loads, a retry row if it failed, and nothing
/// once every page is in. Drop it as the last item of the list you're paging.
class AppPagination extends StatelessWidget {
  const AppPagination({required this.controller, super.key});

  final Paging controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.hasMore.value) return const SizedBox.shrink();

      if (controller.loadingMore.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(
            child: SizedBox(
              width: 20.r,
              height: 20.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (controller.loadMoreError.value != null) {
        final c = context.colors;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(
            child: TextButton.icon(
              onPressed: controller.loadMore,
              icon: Icon(Icons.refresh, size: 18.r, color: c.criticalInk),
              label: Text(Tr.retry.tr),
            ),
          ),
        );
      }

      // Not yet loading — trigger the next page now that this footer is on
      // screen (the caller can also drive this from a scroll listener).
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => controller.loadMore(),
      );
      return SizedBox(height: AppSpacing.xl);
    });
  }
}
