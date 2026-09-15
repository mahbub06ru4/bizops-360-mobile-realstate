import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/extensions/money_format.dart';
import '../../../../../core/localization/translation_keys.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../domain/entities/real_estate_project.dart';
import '../controllers/saved_controller.dart';

/// Saved projects — select up to 3 to compare (roadmap §7 Phase 2).
class SavedScreen extends GetView<SavedController> {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.buyerSavedTitle.tr)),
      body: Obx(
        () => AsyncView<List<RealEstateProject>>(
          value: controller.state.value,
          onRetry: controller.load,
          isEmpty: (v) => v.isEmpty,
          empty: AppEmptyState(message: Tr.buyerSavedEmpty.tr),
          data: (projects) => RefreshIndicator(
            onRefresh: controller.load,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              itemCount: projects.length,
              itemBuilder: (context, i) => _SavedCard(project: projects[i]),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (controller.selectedForCompare.isEmpty) {
          return const SizedBox.shrink();
        }
        return SafeArea(
          minimum: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!controller.canCompare)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(Tr.buyerCompareMinTwo.tr),
                ),
              AppButton(
                label:
                    '${Tr.buyerCompareNow.tr} (${controller.selectedForCompare.length})',
                onPressed: controller.canCompare
                    ? () => Get.toNamed<void>(
                        Routes.buyerCompare,
                        arguments: List<String>.from(
                          controller.selectedForCompare,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SavedCard extends StatelessWidget {
  const _SavedCard({required this.project});

  final RealEstateProject project;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SavedController>();
    final text = Theme.of(context).textTheme;
    final c = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        onTap: () =>
            Get.toNamed<void>(Routes.projectDetail, arguments: project),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(project.title, style: text.titleMedium)),
                IconButton(
                  onPressed: () => controller.unsave(project.id),
                  icon: Icon(Icons.bookmark_remove_outlined, color: c.inkMuted),
                ),
              ],
            ),
            if (project.location != null)
              Text(project.location!.shortLabel, style: text.bodySmall),
            SizedBox(height: AppSpacing.xxs),
            Text(
              project.pricing?.estimatedTotal.toBdt(decimals: false) ?? '',
              style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: AppSpacing.sm),
            Obx(
              () => CheckboxListTile(
                value: controller.isSelected(project.id),
                onChanged: (_) {
                  final ok = controller.toggleCompare(project.id);
                  if (!ok) {
                    AppSnackbar.show(
                      Tr.buyerCompareMax.tr,
                      tone: FeedbackTone.warning,
                    );
                  }
                },
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(Tr.buyerCompare.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
