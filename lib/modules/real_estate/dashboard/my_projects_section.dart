import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/state/async_value.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/real_estate_project.dart';
import '../../../domain/repositories/real_estate_project_repository.dart';
import '../../../presentation/home/widgets/dashboard_section.dart';
import '../projects/bindings/real_estate_bindings.dart';
import '../projects/project_display.dart';

/// Home dashboard: the seller's most recent projects and their verification
/// status. Reuses `RealEstateProjectRepository` (registered permanent on
/// first use, fake or live per `Env.useFakeData`) — no dedicated controller,
/// just a one-shot fetch on first build.
class MyProjectsSection extends StatefulWidget {
  const MyProjectsSection({super.key});

  @override
  State<MyProjectsSection> createState() => _MyProjectsSectionState();
}

class _MyProjectsSectionState extends State<MyProjectsSection> {
  static const _maxRows = 3;

  late final Rx<AsyncValue<List<RealEstateProject>>> _state =
      const AsyncValue<List<RealEstateProject>>.loading().obs;

  @override
  void initState() {
    super.initState();
    ensureRealEstateProjectRepo();
    _load();
  }

  Future<void> _load() async {
    final result = await Get.find<RealEstateProjectRepository>().list();
    _state.value = result.fold(AsyncValue.data, AsyncValue.error);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final projects = _state.value.valueOrNull ?? const <RealEstateProject>[];
      if (projects.isEmpty) return const SizedBox.shrink();

      return DashboardSection(
        title: Tr.homeProjectsSummary.tr,
        onViewAll: () => Get.toNamed<void>(Routes.projects),
        child: Column(
          children: [
            for (var i = 0; i < projects.length.clamp(0, _maxRows); i++) ...[
              if (i > 0) const Divider(height: 1),
              _Row(project: projects[i]),
            ],
          ],
        ),
      );
    });
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.project});

  final RealEstateProject project;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => Get.toNamed<void>(Routes.projectDetail, arguments: project),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                project.title,
                style: text.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            AppStatusChip(
              project.status.labelKey.tr,
              tone: project.status.tone,
            ),
          ],
        ),
      ),
    );
  }
}
