import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/task_item.dart';
import '../task_display.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({required this.task, this.onTap, super.key});

  final TaskItem task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: text.bodyLarge?.copyWith(
                    decoration: task.isDone ? TextDecoration.lineThrough : null,
                    color: task.isDone ? c.inkFaint : null,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              AppStatusChip(task.status.labelKey.tr, tone: task.status.tone),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (task.priority != TaskPriority.normal &&
                  task.priority != TaskPriority.low) ...[
                Icon(Icons.flag_outlined, size: 14, color: c.inkMuted),
                SizedBox(width: AppSpacing.xxs),
                Text(task.priority.labelKey.tr, style: text.bodySmall),
                SizedBox(width: AppSpacing.md),
              ],
              if (task.dueDate != null) ...[
                Icon(
                  Icons.event_outlined,
                  size: 14,
                  color: task.isOverdue ? c.criticalInk : c.inkMuted,
                ),
                SizedBox(width: AppSpacing.xxs),
                Text(
                  DateFormat.MMMd().format(task.dueDate!),
                  style: text.bodySmall?.copyWith(
                    color: task.isOverdue ? c.criticalInk : null,
                  ),
                ),
              ],
              const Spacer(),
              if (task.subtasksTotal > 0) ...[
                Icon(Icons.checklist, size: 14, color: c.inkMuted),
                SizedBox(width: AppSpacing.xxs),
                Text(
                  '${task.subtasksDone}/${task.subtasksTotal}',
                  style: text.bodySmall,
                ),
                SizedBox(width: AppSpacing.md),
              ],
              if (task.commentCount > 0) ...[
                Icon(Icons.mode_comment_outlined, size: 14, color: c.inkMuted),
                SizedBox(width: AppSpacing.xxs),
                Text('${task.commentCount}', style: text.bodySmall),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
