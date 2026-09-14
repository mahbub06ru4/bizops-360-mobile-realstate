import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/permissions/can.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/task_item.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/task_create_sheet.dart';
import '../widgets/task_tile.dart';

/// My tasks, bucketed Today / Overdue / Upcoming.
class TasksScreen extends GetView<TasksController> {
  const TasksScreen({super.key});

  static const _buckets = [
    (TaskBucket.today, Tr.today),
    (TaskBucket.overdue, Tr.overdue),
    (TaskBucket.upcoming, Tr.upcoming),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _buckets.length,
      child: Scaffold(
        floatingActionButton: Can(
          Perm.taskCreate,
          child: FloatingActionButton(
            onPressed: () async {
              final created = await showTaskCreateSheet(controller);
              if (created) {
                AppSnackbar.show(Tr.taskCreated.tr, tone: FeedbackTone.success);
              }
            },
            child: const Icon(Icons.add),
          ),
        ),
        appBar: AppBar(
          title: Text(Tr.navTasks.tr),
          bottom: TabBar(
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
            () => AsyncView<List<TaskItem>>(
              value: controller.state.value,
              onRetry: controller.load,
              data: (_) => TabBarView(
                children: [
                  for (final (bucket, _) in _buckets)
                    _BucketList(items: controller.bucket(bucket)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BucketList extends StatelessWidget {
  const _BucketList({required this.items});

  final List<TaskItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: AppSpacing.xxl),
          AppEmptyState(message: Tr.tasksEmpty.tr),
        ],
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: TaskTile(
          task: items[i],
          onTap: () =>
              Get.toNamed<void>(Routes.taskDetail, arguments: items[i]),
        ),
      ),
    );
  }
}
