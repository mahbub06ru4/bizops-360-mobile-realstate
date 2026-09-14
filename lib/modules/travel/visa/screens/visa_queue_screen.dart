import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/visa_application.dart';
import '../controllers/visa_queue_controller.dart';
import '../visa_display.dart';

/// Visa applications queued by stage. Travel tenants only (gated in the shell).
class VisaQueueScreen extends GetView<VisaQueueController> {
  const VisaQueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.navVisa.tr)),
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
                  for (final stage in VisaStage.values)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(
                          '${stage.labelKey.tr} ${controller.stageCount(stage)}',
                        ),
                        selected: controller.filter.value == stage,
                        onSelected: (_) => controller.toggleFilter(stage),
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
                () => AsyncView<List<VisaApplication>>(
                  value: controller.state.value,
                  onRetry: controller.load,
                  data: (_) {
                    final list = controller.visible;
                    if (list.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: AppSpacing.xxl),
                          const AppEmptyState(),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      itemCount: list.length,
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _VisaCard(application: list[i]),
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

class _VisaCard extends StatelessWidget {
  const _VisaCard({required this.application});

  final VisaApplication application;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => Get.toNamed<void>(Routes.visaDetail, arguments: application),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(application.travellerName, style: text.titleMedium),
              ),
              AppStatusChip(
                application.stage.labelKey.tr,
                tone: application.stage.tone,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            '${application.country} · ${application.category}',
            style: text.bodySmall,
          ),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: application.docProgress,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                '${application.docsCollected}/${application.docs.length}',
                style: text.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
