import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/money_format.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/customer.dart';
import '../../crm/controllers/customers_controller.dart';
import '../../crm/crm_display.dart';

/// The Customers tab — pipeline stage chips over a searchable list.
class CustomersScreen extends GetView<CustomersController> {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.navCustomers.tr)),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSearchField(
              hint: Tr.crmSearch.tr,
              onChanged: (v) => controller.query.value = v,
            ),
          ),
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  for (final stage in PipelineStage.values)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(
                          '${stage.labelKey.tr} ${controller.stageCount(stage)}',
                        ),
                        selected: controller.stageFilter.value == stage,
                        onSelected: (_) => controller.toggleStage(stage),
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
                () => AsyncView<List<Customer>>(
                  value: controller.state.value,
                  onRetry: controller.load,
                  data: (_) {
                    final list = controller.visible;
                    if (list.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: AppSpacing.xxl),
                          AppEmptyState(message: Tr.crmEmpty.tr),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      itemCount: list.length,
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _CustomerCard(customer: list[i]),
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

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () =>
          Get.toNamed<void>(Routes.customerDetail, arguments: customer),
      child: Row(
        children: [
          AppAvatar(name: customer.name),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(customer.name, style: text.titleMedium),
                if (customer.value != null)
                  Text(
                    customer.value!.toBdt(decimals: false),
                    style: text.bodySmall,
                  ),
              ],
            ),
          ),
          AppStatusChip(customer.stage.labelKey.tr, tone: customer.stage.tone),
        ],
      ),
    );
  }
}
