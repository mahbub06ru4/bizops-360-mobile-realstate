import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/money_format.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/entities/leave_request.dart';
import '../../expenses/controllers/expense_approvals_controller.dart';
import '../../expenses/expense_display.dart';
import '../controllers/approvals_controller.dart';
import '../hr_display.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(Tr.approvalsTitle.tr),
          bottom: TabBar(
            tabs: [
              Tab(text: Tr.leaveTitle.tr),
              Tab(text: Tr.expensesTitle.tr),
            ],
          ),
        ),
        body: const TabBarView(children: [_LeaveTab(), _ExpenseTab()]),
      ),
    );
  }
}

class _LeaveTab extends StatelessWidget {
  const _LeaveTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ApprovalsController>();
    return RefreshIndicator(
      onRefresh: controller.load,
      child: Obx(
        () => AsyncView<List<LeaveRequest>>(
          value: controller.pending.value,
          onRetry: controller.load,
          isEmpty: (l) => l.isEmpty,
          empty: AppEmptyState(message: Tr.approvalsEmpty.tr),
          data: (list) => ListView(
            padding: EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final r in list)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _LeaveCard(
                    request: r,
                    busy: controller.actingOn.value == r.id,
                    onDecide: (a) => controller.decide(r.id, approve: a),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseTab extends StatelessWidget {
  const _ExpenseTab();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ExpenseApprovalsController>();
    return RefreshIndicator(
      onRefresh: controller.load,
      child: Obx(
        () => AsyncView<List<Expense>>(
          value: controller.pending.value,
          onRetry: controller.load,
          isEmpty: (l) => l.isEmpty,
          empty: AppEmptyState(message: Tr.approvalsEmpty.tr),
          data: (list) => ListView(
            padding: EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final e in list)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.md),
                  child: _ExpenseCard(
                    expense: e,
                    busy: controller.actingOn.value == e.id,
                    onDecide: (a) => controller.decide(e.id, approve: a),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Decision extends StatelessWidget {
  const _Decision({required this.busy, required this.onDecide});

  final bool busy;
  final ValueChanged<bool> onDecide;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppButton(
            label: Tr.reject.tr,
            variant: AppButtonVariant.secondary,
            loading: busy,
            onPressed: () => onDecide(false),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppButton(
            label: Tr.approve.tr,
            loading: busy,
            onPressed: () => onDecide(true),
          ),
        ),
      ],
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.request,
    required this.busy,
    required this.onDecide,
  });

  final LeaveRequest request;
  final bool busy;
  final ValueChanged<bool> onDecide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final range =
        '${DateFormat.MMMd().format(request.from)} – ${DateFormat.MMMd().format(request.to)}';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: request.requesterName ?? '?', size: 32),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  request.requesterName ?? '',
                  style: text.titleMedium,
                ),
              ),
              AppStatusChip(
                '${request.type.labelKey.tr} · ${Tr.leaveDaysN.trParams({'n': '${request.days}'})}',
                dot: false,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(range, style: text.bodySmall),
          SizedBox(height: AppSpacing.xxs),
          Text(request.reason, style: text.bodyMedium),
          SizedBox(height: AppSpacing.sm),
          _Decision(busy: busy, onDecide: onDecide),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.busy,
    required this.onDecide,
  });

  final Expense expense;
  final bool busy;
  final ValueChanged<bool> onDecide;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(expense.category.icon),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(expense.submittedBy ?? '', style: text.titleMedium),
              ),
              Text(expense.amount.toBdt(), style: text.titleMedium),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            '${expense.category.labelKey.tr} · ${DateFormat.MMMd().format(expense.date)}',
            style: text.bodySmall,
          ),
          if (expense.note != null) ...[
            SizedBox(height: AppSpacing.xxs),
            Text(expense.note!, style: text.bodyMedium),
          ],
          SizedBox(height: AppSpacing.sm),
          _Decision(busy: busy, onDecide: onDecide),
        ],
      ),
    );
  }
}
