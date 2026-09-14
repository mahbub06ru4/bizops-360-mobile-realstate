import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/repositories/crm_repository.dart';
import '../controllers/new_offer_controller.dart';

class NewOfferScreen extends GetView<NewOfferController> {
  const NewOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.offerNew.tr)),
      body: Obx(
        () => ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              '${controller.projectTitle} · ${controller.unitName}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            FutureBuilder(
              future: Get.find<CrmRepository>().customers(),
              builder: (context, snapshot) {
                final leads = snapshot.data?.valueOrNull ?? const <Customer>[];
                return AppDropdown<Customer>(
                  label: Tr.svLead.tr,
                  value: controller.lead.value,
                  items: [
                    for (final l in leads) AppDropdownItem<Customer>(l, l.name),
                  ],
                  onChanged: (v) => controller.lead.value = v,
                );
              },
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.offerAmount.tr,
              keyboardType: TextInputType.number,
              onChanged: (v) => controller.amount.value = v,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.offerNote.tr,
              maxLines: 2,
              onChanged: (v) => controller.note.value = v,
            ),
            if (controller.error.value != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                controller.error.value!,
                style: TextStyle(color: context.colors.criticalInk),
              ),
            ],
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: Tr.offerMake.tr,
              loading: controller.busy.value,
              onPressed: () async {
                final offer = await controller.submit();
                if (offer != null) {
                  AppSnackbar.show(
                    Tr.offerMadeSnackbar.tr,
                    tone: FeedbackTone.success,
                  );
                  Get.back<void>();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
