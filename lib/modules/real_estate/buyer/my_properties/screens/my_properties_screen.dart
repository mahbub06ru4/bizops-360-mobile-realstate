import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../core/extensions/money_format.dart';
import '../../../../../core/localization/translation_keys.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../pipeline_display.dart';
import '../controllers/my_properties_controller.dart';

/// The buyer "My Properties" dashboard — paid / remaining / next-due plus an
/// installment timeline per booking (roadmap §7 Phase 2). Reuses the Phase 1
/// booking/installment entities and `pipeline_display.dart`'s status
/// chip/label helpers rather than inventing a parallel display layer.
class MyPropertiesScreen extends GetView<MyPropertiesController> {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.buyerMyPropertiesTitle.tr)),
      body: Obx(
        () => AsyncView<List<MyPropertyRow>>(
          value: controller.state.value,
          onRetry: controller.load,
          isEmpty: (v) => v.isEmpty,
          empty: AppEmptyState(message: Tr.buyerMyPropertiesEmpty.tr),
          data: (rows) => RefreshIndicator(
            onRefresh: controller.load,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              itemCount: rows.length,
              itemBuilder: (context, i) => _PropertyCard(row: rows[i]),
            ),
          ),
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  const _PropertyCard({required this.row});

  final MyPropertyRow row;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    final booking = row.booking;
    final nextDue = row.nextDue;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${booking.projectTitle} · ${booking.unitName}',
                    style: text.titleMedium,
                  ),
                ),
                AppStatusChip(
                  booking.status.labelKey.tr,
                  tone: booking.status.tone,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _stat(context, Tr.buyerPaid.tr, row.paidAmount, c.brandInk),
                _stat(
                  context,
                  Tr.buyerRemaining.tr,
                  row.remainingAmount,
                  c.ink,
                ),
              ],
            ),
            if (nextDue != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                '${Tr.buyerNextDue.tr}: ${nextDue.amount.toBdt(decimals: false)} · '
                '${DateFormat.yMMMd().format(nextDue.dueDate)}',
                style: text.bodyMedium,
              ),
            ],
            if (row.plan != null) ...[
              SizedBox(height: AppSpacing.md),
              AppSectionLabel(Tr.buyerInstallmentTimeline.tr),
              for (final inst in row.plan!.installments)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '#${inst.sequence} · ${DateFormat.yMMMd().format(inst.dueDate)}',
                          style: text.bodySmall,
                        ),
                      ),
                      Text(
                        inst.amount.toBdt(decimals: false),
                        style: AppTypography.mono(c.ink),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      AppStatusChip(
                        inst.status.labelKey.tr,
                        tone: inst.status.tone,
                        dot: false,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, num amount, Color color) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodySmall),
          Text(
            amount.toBdt(decimals: false),
            style: AppTypography.mono(color, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
