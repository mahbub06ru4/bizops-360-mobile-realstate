import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/money_format.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/expense.dart';
import '../controllers/expenses_controller.dart';
import '../expense_display.dart';

class ExpensesScreen extends GetView<ExpensesController> {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.expensesTitle.tr)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Get.toNamed<bool>(Routes.expenseNew);
          if (ok ?? false) {
            AppSnackbar.show(
              Tr.expenseSubmitted.tr,
              tone: FeedbackTone.success,
            );
          }
        },
        icon: const Icon(Icons.add),
        label: Text(Tr.expenseNew.tr),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<Expense>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (l) => l.isEmpty,
            empty: AppEmptyState(message: Tr.expenseEmpty.tr),
            data: (list) => ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl + AppSpacing.xl,
              ),
              itemCount: list.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ExpenseCard(expense: list[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Row(
        children: [
          Icon(
            expense.category.icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${expense.category.labelKey.tr} · ${DateFormat.MMMd().format(expense.date)}',
                  style: text.bodySmall,
                ),
                Text(
                  expense.amount.toBdt(),
                  style: AppTypography.mono(
                    Theme.of(context).colorScheme.onSurface,
                    size: 15,
                  ),
                ),
                if (expense.note != null)
                  Text(
                    expense.note!,
                    style: text.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          AppStatusChip(expense.status.labelKey.tr, tone: expense.status.tone),
        ],
      ),
    );
  }
}
