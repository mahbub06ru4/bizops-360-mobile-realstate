import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/task_comment.dart';
import '../../../domain/entities/task_item.dart';
import '../controllers/task_detail_controller.dart';
import '../task_display.dart';

class TaskDetailScreen extends GetView<TaskDetailController> {
  const TaskDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.navTasks.tr)),
      body: Obx(
        () => AsyncView<TaskItem>(
          value: controller.state.value,
          onRetry: controller.reload,
          data: _body,
        ),
      ),
      bottomNavigationBar: Obx(() {
        final task = controller.state.value.valueOrNull;
        if (task == null) return const SizedBox.shrink();
        return SafeArea(
          minimum: EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: task.isDone ? Tr.taskReopen.tr : Tr.taskMarkDone.tr,
            loading: controller.updating.value,
            icon: task.isDone ? Icons.undo : Icons.check,
            onPressed: controller.toggleDone,
          ),
        );
      }),
    );
  }

  Widget _body(TaskItem task) {
    return Builder(
      builder: (context) {
        final c = context.colors;
        final text = Theme.of(context).textTheme;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text(task.title, style: text.headlineSmall),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                AppStatusChip(task.status.labelKey.tr, tone: task.status.tone),
                AppStatusChip(
                  task.priority.labelKey.tr,
                  tone: task.priority.tone,
                  dot: false,
                ),
                if (task.dueDate != null)
                  AppStatusChip(
                    '${Tr.taskDue.tr}: ${DateFormat.MMMd().format(task.dueDate!)}',
                    tone: task.isOverdue ? ChipTone.critical : ChipTone.neutral,
                    dot: false,
                  ),
              ],
            ),
            if (task.description != null) ...[
              SizedBox(height: AppSpacing.lg),
              Text(task.description!, style: text.bodyLarge),
            ],
            if (task.subtasks.isNotEmpty) ...[
              SizedBox(height: AppSpacing.xl),
              AppSectionLabel(
                '${Tr.taskSubtasks.tr} · ${task.subtasksDone}/${task.subtasksTotal}',
              ),
              SizedBox(height: AppSpacing.xs),
              LinearProgressIndicator(
                value: task.subtaskProgress,
                borderRadius: AppRadius.brPill,
                minHeight: 6,
                backgroundColor: c.surfaceAlt,
              ),
              SizedBox(height: AppSpacing.sm),
              for (final s in task.subtasks)
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: s.done,
                  onChanged: (v) => controller.toggleSubtask(s.id, v ?? false),
                  title: Text(s.title),
                ),
            ],
            SizedBox(height: AppSpacing.xl),
            Obx(() {
              final list = controller.comments.value.valueOrNull ?? const [];
              return AppSectionLabel('${Tr.taskComments.tr} · ${list.length}');
            }),
            SizedBox(height: AppSpacing.xs),
            Obx(
              () => AsyncView<List<TaskComment>>(
                value: controller.comments.value,
                isEmpty: (l) => l.isEmpty,
                empty: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(Tr.taskNoComments.tr, style: text.bodyMedium),
                ),
                data: (list) => Column(
                  children: [
                    for (final m in list)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppAvatar(name: m.author, size: 32),
                            SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${m.author} · ${DateFormat.MMMd().add_jm().format(m.at)}',
                                    style: text.bodySmall,
                                  ),
                                  Text(m.body, style: text.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Obx(
              () => _CommentComposer(
                sending: controller.sendingComment.value,
                onSend: controller.addComment,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CommentComposer extends StatefulWidget {
  const _CommentComposer({required this.onSend, required this.sending});

  final Future<void> Function(String) onSend;
  final bool sending;

  @override
  State<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<_CommentComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text;
    if (text.trim().isEmpty || widget.sending) return;
    await widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: Tr.taskAddComment.tr,
      controller: _controller,
      onSubmitted: (_) => _submit(),
      suffixIcon: IconButton(
        onPressed: widget.sending ? null : _submit,
        icon: const Icon(Icons.send_outlined, size: 20),
      ),
    );
  }
}
