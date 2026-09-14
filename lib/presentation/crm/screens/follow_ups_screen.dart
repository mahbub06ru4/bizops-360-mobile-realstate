import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/follow_up.dart';
import '../controllers/follow_ups_controller.dart';
import '../crm_display.dart';

class FollowUpsScreen extends GetView<FollowUpsController> {
  const FollowUpsScreen({super.key});

  static const _buckets = [
    (FollowUpBucket.today, Tr.today),
    (FollowUpBucket.overdue, Tr.overdue),
    (FollowUpBucket.upcoming, Tr.upcoming),
    (FollowUpBucket.done, Tr.taskStatusDone),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _buckets.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Tr.followUpsTitle.tr),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final (bucket, key) in _buckets)
                Obx(() {
                  final n = controller.countOf(bucket);
                  return Tab(text: n == 0 ? key.tr : '${key.tr} ($n)');
                }),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: controller.load,
          child: Obx(
            () => AsyncView<List<FollowUp>>(
              value: controller.state.value,
              onRetry: controller.load,
              data: (_) => TabBarView(
                children: [
                  for (final (bucket, _) in _buckets)
                    _BucketList(
                      items: controller.bucket(bucket),
                      onComplete: (f) => _logOutcome(context, f),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _logOutcome(BuildContext context, FollowUp f) async {
    await AppBottomSheet.show<void>(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Tr.followUpLogOutcome.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          for (final o in FollowUpOutcome.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(o.labelKey.tr),
              onTap: () {
                controller.complete(f.id, o);
                Get.back<void>();
              },
            ),
        ],
      ),
    );
  }
}

class _BucketList extends StatelessWidget {
  const _BucketList({required this.items, required this.onComplete});

  final List<FollowUp> items;
  final ValueChanged<FollowUp> onComplete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: AppSpacing.xxl),
          const AppEmptyState(),
        ],
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      itemBuilder: (context, i) => Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: _FollowUpCard(followUp: items[i], onComplete: onComplete),
      ),
    );
  }
}

class _FollowUpCard extends StatelessWidget {
  const _FollowUpCard({required this.followUp, required this.onComplete});

  final FollowUp followUp;
  final ValueChanged<FollowUp> onComplete;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(followUp.channel.icon, size: 20, color: c.inkMuted),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(followUp.customerName, style: text.titleMedium),
                Text(followUp.note, style: text.bodyMedium),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  DateFormat.MMMd().format(followUp.dueAt),
                  style: text.bodySmall?.copyWith(
                    color: followUp.isOverdue ? c.criticalInk : null,
                  ),
                ),
              ],
            ),
          ),
          if (followUp.done)
            AppStatusChip(
              followUp.outcome?.labelKey.tr ?? Tr.taskStatusDone.tr,
              tone: ChipTone.brand,
              dot: false,
            )
          else
            IconButton(
              onPressed: () => onComplete(followUp),
              icon: const Icon(Icons.check_circle_outline),
            ),
        ],
      ),
    );
  }
}
