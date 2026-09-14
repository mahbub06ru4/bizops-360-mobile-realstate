import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/task_item.dart';
import '../controllers/tasks_controller.dart';
import '../task_display.dart';

/// Returns true when a task was created.
Future<bool> showTaskCreateSheet(TasksController controller) async {
  final r = await AppBottomSheet.show<bool>(_TaskCreateForm(controller));
  return r ?? false;
}

class _TaskCreateForm extends StatefulWidget {
  const _TaskCreateForm(this.controller);

  final TasksController controller;

  @override
  State<_TaskCreateForm> createState() => _TaskCreateFormState();
}

class _TaskCreateFormState extends State<_TaskCreateForm> {
  final _title = TextEditingController();
  final _assignee = TextEditingController();

  TaskPriority _priority = TaskPriority.normal;
  DateTime? _due;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _assignee.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    final ok = await widget.controller.create(
      title: _title.text.trim(),
      priority: _priority,
      dueDate: _due,
      assigneeName: _assignee.text.trim().isEmpty
          ? null
          : _assignee.text.trim(),
    );
    setState(() => _submitting = false);
    if (ok && mounted) Get.back<bool>(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(Tr.taskNew.tr, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: AppSpacing.md),
        AppTextField(label: Tr.taskTitle.tr, controller: _title, maxLines: 2),
        SizedBox(height: AppSpacing.md),
        Text(Tr.taskPriority.tr, style: Theme.of(context).textTheme.bodySmall),
        SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final p in TaskPriority.values)
              ChoiceChip(
                label: Text(p.labelKey.tr),
                selected: _priority == p,
                onSelected: (_) => setState(() => _priority = p),
              ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(label: Tr.taskAssignee.tr, controller: _assignee),
        SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _due ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) setState(() => _due = picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: Tr.taskDueDate.tr,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
            ),
            child: Text(_due == null ? '—' : DateFormat.yMMMd().format(_due!)),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AppButton(label: Tr.save.tr, loading: _submitting, onPressed: _submit),
      ],
    );
  }
}
