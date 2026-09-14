import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/navigation/shell_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/visa_application.dart';
import '../../../presentation/home/widgets/dashboard_section.dart';
import '../visa/controllers/visa_queue_controller.dart';

/// Home dashboard: a glance at the visa pipeline, read live from the same
/// [VisaQueueController] the Visa tab uses (registered permanent in the shell).
class VisaSummarySection extends StatelessWidget {
  const VisaSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaQueueController>();

    return Obx(() {
      final apps = controller.state.value.valueOrNull ?? const [];
      final awaitingDocs = apps
          .where((a) => !a.allDocsCollected && !a.isDecided)
          .length;
      final inProgress = apps
          .where(
            (a) =>
                a.stage == VisaStage.submitted ||
                a.stage == VisaStage.processing,
          )
          .length;
      final decisionDue = apps
          .where((a) => a.stage == VisaStage.processing)
          .length;

      return DashboardSection(
        title: Tr.homeVisaSummary.tr,
        onViewAll: () => Get.find<ShellController>().selectTab(ShellTabId.visa),
        child: Row(
          children: [
            _Stat(inProgress, Tr.homeVisaInProgress.tr),
            const _Divider(),
            _Stat(awaitingDocs, Tr.homeVisaAwaitingDocs.tr),
            const _Divider(),
            _Stat(decisionDue, Tr.homeVisaDecisionDue.tr),
          ],
        ),
      );
    });
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: text.displaySmall),
          SizedBox(height: AppSpacing.xxs),
          Text(label, style: text.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: Theme.of(context).colorScheme.outline,
    );
  }
}
