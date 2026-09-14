import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/visa_application.dart';
import '../../../presentation/home/widgets/dashboard_section.dart';
import '../visa/controllers/visa_queue_controller.dart';

/// Home dashboard: the visa cases still missing documents, soonest to submit
/// first. Reads the same live [VisaQueueController] as the Visa tab.
class PendingVisaDocsSection extends StatelessWidget {
  const PendingVisaDocsSection({super.key});

  static const _maxRows = 3;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VisaQueueController>();

    return Obx(() {
      final pending =
          (controller.state.value.valueOrNull ?? const <VisaApplication>[])
              .where((a) => !a.allDocsCollected && !a.isDecided)
              .toList()
            ..sort((a, b) => b.docProgress.compareTo(a.docProgress));

      if (pending.isEmpty) return const SizedBox.shrink();

      return DashboardSection(
        title: Tr.homeVisaDocs.tr,
        trailing: Padding(
          padding: EdgeInsets.only(right: AppSpacing.sm),
          child: AppBadge(count: pending.length),
        ),
        child: Column(
          children: [
            for (var i = 0; i < pending.length.clamp(0, _maxRows); i++) ...[
              if (i > 0) const Divider(height: 1),
              _Row(app: pending[i]),
            ],
          ],
        ),
      );
    });
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.app});

  final VisaApplication app;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => Get.toNamed<void>(Routes.visaDetail, arguments: app),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${app.travellerName} · ${app.country}',
                style: text.bodyLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              '${app.docsCollected}/${app.docs.length}',
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
