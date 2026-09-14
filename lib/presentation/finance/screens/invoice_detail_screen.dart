import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/money_format.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/invoice.dart';
import '../controllers/invoice_detail_controller.dart';
import '../invoice_display.dart';
import 'record_payment_sheet.dart';

class InvoiceDetailScreen extends GetView<InvoiceDetailController> {
  const InvoiceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.state.value.valueOrNull?.reference ??
                Tr.invoicesTitle.tr,
          ),
        ),
      ),
      body: Obx(
        () => AsyncView<Invoice>(
          value: controller.state.value,
          onRetry: controller.reload,
          data: (i) => _body(context, i),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final i = controller.state.value.valueOrNull;
        if (i == null || i.isSettled) return const SizedBox.shrink();
        return SafeArea(
          minimum: EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: Tr.invRecordPayment.tr,
            loading: controller.busy.value,
            icon: Icons.add_card_outlined,
            onPressed: () async {
              final ok = await showRecordPaymentSheet(controller);
              if (ok) {
                AppSnackbar.show(
                  Tr.invPaymentRecorded.tr,
                  tone: FeedbackTone.success,
                );
              }
            },
          ),
        );
      }),
    );
  }

  Widget _body(BuildContext context, Invoice i) {
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
        Row(
          children: [
            Expanded(child: Text(i.customerName, style: text.titleMedium)),
            AppStatusChip(i.status.labelKey.tr, tone: i.status.tone),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        AppCard(
          child: Column(
            children: [
              _kv(context, Tr.invAmount.tr, i.amount.toBdt(), mono: true),
              _kv(context, Tr.invPaid.tr, i.paidAmount.toBdt(), mono: true),
              _kv(
                context,
                Tr.invDue.tr,
                i.due.toBdt(),
                mono: true,
                emphasise: i.due > 0,
              ),
              _kv(
                context,
                Tr.invDueDate.tr,
                DateFormat.yMMMEd().format(i.dueDate),
              ),
              if (i.bookingReference != null)
                _kv(context, Tr.invBooking.tr, i.bookingReference!, mono: true),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        AppSectionLabel('${Tr.invPayments.tr} · ${i.payments.length}'),
        SizedBox(height: AppSpacing.xs),
        if (i.payments.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(Tr.invNoPayments.tr, style: text.bodyMedium),
          )
        else
          for (final p in i.payments)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.check_circle_outline, color: c.brand),
              title: Text(p.method),
              subtitle: p.note == null ? null : Text(p.note!),
              trailing: Text(
                p.amount.toBdt(decimals: false),
                style: AppTypography.mono(c.ink),
              ),
            ),
      ],
    );
  }

  Widget _kv(
    BuildContext context,
    String k,
    String v, {
    bool mono = false,
    bool emphasise = false,
  }) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(k, style: text.bodyMedium)),
          Text(
            v,
            style: mono
                ? AppTypography.mono(
                    emphasise ? c.criticalInk : c.ink,
                    weight: emphasise ? FontWeight.w600 : FontWeight.w500,
                  )
                : text.titleMedium?.copyWith(
                    color: emphasise ? c.criticalInk : null,
                  ),
          ),
        ],
      ),
    );
  }
}
