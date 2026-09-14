import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/money_format.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/invoice.dart';
import '../controllers/invoices_controller.dart';
import '../invoice_display.dart';

class InvoicesScreen extends GetView<InvoicesController> {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.invoicesTitle.tr)),
      body: Column(
        children: [
          Obx(() {
            final outstanding = controller.outstanding;
            if (outstanding <= 0) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        Tr.invOutstanding.tr,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      outstanding.toBdt(decimals: false),
                      style: AppTypography.mono(
                        context.colors.criticalInk,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  for (final s in InvoiceStatus.values)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(s.labelKey.tr),
                        selected: controller.statusFilter.value == s,
                        onSelected: (_) => controller.toggleStatus(s),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: Obx(
                () => AsyncView<List<Invoice>>(
                  value: controller.state.value,
                  onRetry: controller.load,
                  data: (_) {
                    final list = controller.visible;
                    if (list.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: AppSpacing.xxl),
                          const AppEmptyState(),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      itemCount: list.length,
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _InvoiceCard(invoice: list[i]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: () => Get.toNamed<void>(Routes.invoiceDetail, arguments: invoice),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  invoice.reference,
                  style: AppTypography.mono(c.ink),
                ),
              ),
              AppStatusChip(
                invoice.status.labelKey.tr,
                tone: invoice.status.tone,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(invoice.customerName, style: text.bodyLarge),
          SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Text(
                '${Tr.invDueDate.tr} ${DateFormat.MMMd().format(invoice.dueDate)}',
                style: text.bodySmall?.copyWith(
                  color: invoice.isPastDue ? c.criticalInk : null,
                ),
              ),
              const Spacer(),
              Text(
                invoice.amount.toBdt(decimals: false),
                style: AppTypography.mono(c.ink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
