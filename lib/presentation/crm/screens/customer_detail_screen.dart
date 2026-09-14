import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/extensions/money_format.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/customer.dart';
import '../controllers/customer_detail_controller.dart';
import '../crm_display.dart';

class CustomerDetailScreen extends GetView<CustomerDetailController> {
  const CustomerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.customer.value.valueOrNull?.name ?? ''),
        ),
      ),
      body: Obx(
        () => AsyncView<Customer>(
          value: controller.customer.value,
          data: (c) => _body(context, c),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Customer c) {
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
            AppAvatar(name: c.name, size: 52),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: text.headlineSmall),
                  if (c.phone != null) Text(c.phone!, style: text.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: Tr.crmCall.tr,
                icon: Icons.call,
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppButton(
                label: Tr.crmMessage.tr,
                icon: Icons.chat_bubble_outline,
                variant: AppButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            children: [
              _Field(
                Tr.crmMoveStage.tr,
                null,
                trailing: DropdownButton<PipelineStage>(
                  value: c.stage,
                  underline: const SizedBox.shrink(),
                  items: [
                    for (final s in PipelineStage.values)
                      DropdownMenuItem(value: s, child: Text(s.labelKey.tr)),
                  ],
                  onChanged: (s) {
                    if (s != null) controller.moveStage(s);
                  },
                ),
              ),
              if (c.value != null)
                _Field(Tr.crmValue.tr, c.value!.toBdt(decimals: false)),
              if (c.source != null) _Field(Tr.crmSource.tr, c.source!),
            ],
          ),
        ),
        if (c.note != null) ...[
          SizedBox(height: AppSpacing.md),
          Text(c.note!, style: text.bodyLarge),
        ],
        SizedBox(height: AppSpacing.xl),
        AppSectionLabel(Tr.crmHistory.tr),
        SizedBox(height: AppSpacing.xs),
        Obx(
          () => AsyncView<List<CustomerActivity>>(
            value: controller.history.value,
            isEmpty: (l) => l.isEmpty,
            data: (items) => Column(
              children: [
                for (final a in items)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.circle, size: 8),
                    title: Text(a.summary),
                    subtitle: a.detail == null ? null : Text(a.detail!),
                    trailing: Text(
                      DateFormat.MMMd().format(a.at),
                      style: text.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value, {this.trailing});

  final String label;
  final String? value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text.bodyMedium)),
          if (value != null) Text(value!, style: text.titleMedium),
          ?trailing,
        ],
      ),
    );
  }
}
