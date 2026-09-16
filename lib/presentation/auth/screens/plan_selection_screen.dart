import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/billing_plan.dart';
import '../controllers/plan_selection_controller.dart';

class PlanSelectionScreen extends GetView<PlanSelectionController> {
  const PlanSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(Tr.planTitle.tr)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(Tr.planSubtitle.tr, style: text.bodyMedium),
            ),
            Expanded(
              child: Obx(
                () => AsyncView<List<BillingPlan>>(
                  value: controller.state.value,
                  onRetry: controller.load,
                  isEmpty: (list) => list.isEmpty,
                  empty: AppEmptyState(
                    icon: Icons.workspace_premium_outlined,
                    message: Tr.planEmpty.tr,
                  ),
                  data: (plans) => ListView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    children: [
                      for (final plan in plans)
                        _PlanCard(plan: plan, controller: controller),
                      SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
            Obx(() {
              final err = controller.formError.value;
              if (err == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  err,
                  style: text.bodySmall?.copyWith(
                    color: context.colors.criticalInk,
                  ),
                ),
              );
            }),
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Obx(
                () => FilledButton(
                  onPressed:
                      controller.submitting.value ||
                          controller.selectedCode.value == null
                      ? null
                      : controller.confirm,
                  child: controller.submitting.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(Tr.planContinue.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.controller});

  final BillingPlan plan;
  final PlanSelectionController controller;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Obx(() {
      final selected = controller.selectedCode.value == plan.code;
      return Card(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? c.brand : c.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => controller.select(plan.code),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(plan.name, style: text.titleMedium)),
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected ? c.brand : c.inkMuted,
                    ),
                  ],
                ),
                Text(
                  '৳ ${plan.priceAmount.toStringAsFixed(0)} / ${plan.billingInterval}',
                  style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: AppSpacing.sm),
                for (final feature in plan.features)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xxs),
                    child: Row(
                      children: [
                        Icon(Icons.check, size: 16, color: c.brand),
                        SizedBox(width: AppSpacing.xs),
                        Expanded(child: Text(feature, style: text.bodySmall)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
