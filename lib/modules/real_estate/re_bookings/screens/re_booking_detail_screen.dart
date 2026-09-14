import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/money_format.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/installment.dart';
import '../../../../domain/entities/real_estate_booking.dart';
import '../../pipeline_display.dart';
import '../controllers/re_booking_detail_controller.dart';

class ReBookingDetailScreen extends GetView<ReBookingDetailController> {
  const ReBookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.bookTitle.tr)),
      body: Obx(
        () => AsyncView<RealEstateBooking>(
          value: controller.booking.value,
          data: (b) => _body(context, b),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, RealEstateBooking b) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;

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
            Expanded(child: Text(b.leadName, style: text.titleLarge)),
            AppStatusChip(b.status.labelKey.tr, tone: b.status.tone),
          ],
        ),
        SizedBox(height: AppSpacing.xs),
        Text('${b.projectTitle} · ${b.unitName}', style: text.bodyMedium),
        SizedBox(height: AppSpacing.md),
        AppCard(
          child: Row(
            children: [
              Expanded(child: Text(Tr.bookPrice.tr, style: text.bodyMedium)),
              Text(
                b.agreedPrice.toBdt(),
                style: AppTypography.mono(c.brandInk, weight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (controller.error.value != null) ...[
          SizedBox(height: AppSpacing.sm),
          Text(controller.error.value!, style: TextStyle(color: c.criticalInk)),
        ],
        if (b.status == RealEstateBookingStatus.reserved) ...[
          SizedBox(height: AppSpacing.md),
          Can(
            Perm.bookingManage,
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: Tr.bookCancel.tr,
                    variant: AppButtonVariant.secondary,
                    onPressed: controller.cancel,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: Tr.bookConfirm.tr,
                    loading: controller.busy.value,
                    onPressed: controller.confirm,
                  ),
                ),
              ],
            ),
          ),
        ],
        SizedBox(height: AppSpacing.lg),
        AppSectionLabel(Tr.bookInstallmentPlan.tr),
        Obx(() {
          if (controller.loadingPlan.value) return const AppLoader();
          final plan = controller.plan.value;
          if (plan == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Text(Tr.bookNoPlan.tr, style: text.bodyMedium),
                ),
                Can(
                  Perm.bookingManage,
                  child: AppButton(
                    label: Tr.bookCreatePlan.tr,
                    expand: false,
                    onPressed: () => _showCreatePlanSheet(context, b),
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              for (final installment in controller.installments)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _InstallmentRow(installment: installment),
                ),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _showCreatePlanSheet(BuildContext context, RealEstateBooking b) {
    final downController = TextEditingController(text: '20');
    final countController = TextEditingController(text: '6');
    return AppBottomSheet.show<void>(
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Tr.bookCreatePlan.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.bookDownPayment.tr,
              controller: downController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.bookInstallmentCount.tr,
              controller: countController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSpacing.lg),
            Obx(
              () => AppButton(
                label: Tr.bookCreatePlan.tr,
                loading: controller.busy.value,
                onPressed: () async {
                  final down = num.tryParse(downController.text.trim());
                  final count = int.tryParse(countController.text.trim());
                  if (down == null || count == null || count <= 0) return;
                  final ok = await controller.createPlan(
                    downPaymentPercent: down,
                    installmentCount: count,
                  );
                  if (ok) Get.back<void>();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstallmentRow extends StatelessWidget {
  const _InstallmentRow({required this.installment});

  final Installment installment;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final controller = Get.find<ReBookingDetailController>();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '#${installment.sequence} · ${installment.amount.toBdt(decimals: false)}',
                  style: text.bodyLarge,
                ),
              ),
              AppStatusChip(
                installment.status.labelKey.tr,
                tone: installment.status.tone,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            '${Tr.instDue.tr}: ${DateFormat.yMMMd().format(installment.dueDate)}',
            style: text.bodySmall,
          ),
          if (installment.status == InstallmentStatus.pending ||
              installment.status == InstallmentStatus.overdue) ...[
            SizedBox(height: AppSpacing.sm),
            Can(
              Perm.installmentManage,
              child: AppButton(
                label: Tr.instGenerateInvoice.tr,
                variant: AppButtonVariant.secondary,
                expand: false,
                onPressed: () async {
                  final invoiceId = await controller.generateInvoice(
                    installment.id,
                  );
                  if (invoiceId != null) {
                    AppSnackbar.show(
                      Tr.instInvoiceGenerated.tr,
                      tone: FeedbackTone.success,
                    );
                  }
                },
              ),
            ),
          ],
          if (installment.status == InstallmentStatus.invoiced) ...[
            SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: Tr.instViewInvoice.tr,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => Get.toNamed<void>(
                      Routes.invoiceDetail,
                      arguments: installment.invoiceId,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Can(
                    Perm.installmentManage,
                    child: AppButton(
                      label: Tr.instMarkPaid.tr,
                      onPressed: () =>
                          controller.markPaid(installment.id).then((ok) {
                            if (ok) {
                              AppSnackbar.show(
                                Tr.instMarkedPaid.tr,
                                tone: FeedbackTone.success,
                              );
                            }
                          }),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
