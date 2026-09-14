import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/money_format.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/property_match.dart';
import '../../pipeline_display.dart';
import '../controllers/matches_controller.dart';

class MatchesScreen extends GetView<MatchesController> {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.reqMatchesTitle.tr),
        actions: [
          Obx(
            () => IconButton(
              icon: controller.rematching.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              tooltip: Tr.reqRematch.tr,
              onPressed: controller.rematching.value
                  ? null
                  : controller.rematch,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<PropertyMatch>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (l) => l.isEmpty,
            empty: ListView(
              children: [
                SizedBox(height: AppSpacing.xxl),
                AppEmptyState(message: Tr.reqMatchesEmpty.tr),
              ],
            ),
            data: (matches) => ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: matches.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _MatchCard(match: matches[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.match});

  final PropertyMatch match;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final tone = match.matchScore >= 70
        ? ChipTone.brand
        : (match.matchScore >= 40 ? ChipTone.signal : ChipTone.neutral);
    final unit = match.unit;
    final price = unit == null || unit.prices.isEmpty
        ? null
        : unit.prices.first.amount;

    return AppCard(
      onTap: match.projectId == null
          ? null
          : () => Get.toNamed<void>(
              Routes.projectDetail,
              arguments: match.projectId,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  unit?.unitNumber ?? match.unitId,
                  style: text.titleMedium,
                ),
              ),
              AppStatusChip('${match.matchScore.toInt()}%', tone: tone),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          AppStatusChip(match.status.labelKey.tr, tone: match.status.tone),
          if (price != null) ...[
            SizedBox(height: AppSpacing.xxs),
            Text(price.toBdt(decimals: false), style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}
