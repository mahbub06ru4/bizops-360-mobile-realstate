import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/extensions/money_format.dart';
import '../../../../../core/localization/translation_keys.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../domain/entities/real_estate_project.dart';
import '../../../projects/project_display.dart';
import '../controllers/browse_controller.dart';

/// Buyer-facing browse — verified listings only, filterable by a Bangladesh
/// location/landmark keyword search (roadmap §7 Phase 2 DoD: "a buyer browses
/// only verified listings").
class BrowseScreen extends GetView<BrowseController> {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.buyerBrowseTitle.tr)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: AppSearchField(
              hint: Tr.buyerSearchHint.tr,
              onChanged: controller.search,
            ),
          ),
          Expanded(
            child: Obx(
              () => AsyncView<List<RealEstateProject>>(
                value: controller.state.value,
                onRetry: controller.load,
                isEmpty: (v) => v.isEmpty,
                empty: AppEmptyState(
                  message: controller.query.value.isEmpty
                      ? Tr.buyerBrowseEmpty.tr
                      : Tr.buyerNoResults.tr,
                ),
                data: (projects) => RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, i) =>
                        _ProjectCard(project: projects[i]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({required this.project});

  final RealEstateProject project;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BrowseController>();
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
                Icon(project.type.icon, color: c.inkMuted),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(project.title, style: text.titleMedium)),
                AppStatusChip(
                  project.status.labelKey.tr,
                  tone: project.status.tone,
                ),
              ],
            ),
            if (project.location != null) ...[
              SizedBox(height: AppSpacing.xxs),
              Text(project.location!.shortLabel, style: text.bodySmall),
            ],
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.pricing?.estimatedTotal.toBdt(decimals: false) ??
                        '',
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Obx(
                  () => IconButton(
                    tooltip: controller.isSaved(project.id)
                        ? Tr.buyerUnsave.tr
                        : Tr.buyerSave.tr,
                    onPressed: () => controller.toggleSave(project.id),
                    icon: Icon(
                      controller.isSaved(project.id)
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      color: controller.isSaved(project.id)
                          ? c.brand
                          : c.inkMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
