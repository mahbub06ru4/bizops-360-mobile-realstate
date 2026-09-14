import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../controllers/projects_controller.dart';
import '../project_display.dart';

/// The seller's own project list — Phase 0 has no buyer-facing browse/search
/// yet, so there is exactly one list screen and it always shows "my projects".
class ProjectsScreen extends GetView<ProjectsController> {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.projTitle.tr)),
      floatingActionButton: Can(
        Perm.projectManage,
        child: FloatingActionButton.extended(
          onPressed: () => Get.toNamed<void>(Routes.postProject),
          icon: const Icon(Icons.add),
          label: Text(Tr.projNew.tr),
        ),
      ),
      body: Column(
        children: [
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  for (final s in ProjectStatus.values)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(s.labelKey.tr),
                        selected: controller.statusFilter.value == s,
                        onSelected: (_) => controller.toggleStatus(s),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: Obx(
                () => AsyncView<List<RealEstateProject>>(
                  value: controller.state.value,
                  onRetry: controller.load,
                  data: (_) {
                    final list = controller.visible;
                    if (list.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: AppSpacing.xxl),
                          AppEmptyState(message: Tr.projEmpty.tr),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      itemCount: list.length,
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ProjectCard(project: list[i]),
                      ),
                    );
                  },
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
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: () => Get.toNamed<void>(Routes.projectDetail, arguments: project),
      child: Row(
        children: [
          Icon(project.type.icon, color: c.inkMuted),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  style: text.bodyLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  [
                    project.type.labelKey.tr,
                    if (project.location != null) project.location!.shortLabel,
                  ].where((s) => s.isNotEmpty).join(' · '),
                  style: text.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          AppStatusChip(project.status.labelKey.tr, tone: project.status.tone),
        ],
      ),
    );
  }
}
