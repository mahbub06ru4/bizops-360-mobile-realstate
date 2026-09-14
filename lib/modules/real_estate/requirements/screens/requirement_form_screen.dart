import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/property_requirement.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../pipeline_display.dart';
import '../../projects/project_display.dart';
import '../controllers/requirement_form_controller.dart';

/// Captures a buyer/lead's structured requirement, reachable from the
/// existing CRM lead detail screen — this never duplicates the lead entity,
/// it only attaches a requirement to it (roadmap §7).
class RequirementFormScreen extends GetView<RequirementFormController> {
  const RequirementFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.reqCapture.tr)),
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
              controller.leadName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: AppSpacing.lg),
            AppDropdown<ProjectType?>(
              label: Tr.reqType.tr,
              value: controller.unitType.value,
              items: [
                for (final t in ProjectType.values)
                  AppDropdownItem<ProjectType?>(t, t.labelKey.tr, icon: t.icon),
              ],
              onChanged: (v) => controller.unitType.value = v,
            ),
            SizedBox(height: AppSpacing.md),
            AppDropdown<RequirementPurpose>(
              label: Tr.reqPurpose.tr,
              value: controller.purpose.value,
              items: [
                for (final p in RequirementPurpose.values)
                  AppDropdownItem<RequirementPurpose>(p, p.labelKey.tr),
              ],
              onChanged: (v) {
                if (v != null) controller.purpose.value = v;
              },
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: Tr.reqMinBudget.tr,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => controller.minBudget.value = v,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppTextField(
                    label: Tr.reqMaxBudget.tr,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => controller.maxBudget.value = v,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.reqBedroomsMin.tr,
              keyboardType: TextInputType.number,
              onChanged: (v) => controller.bedroomsMin.value = v,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.reqPreferredLocations.tr,
              onChanged: (v) => controller.preferredLocations.value = v,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.reqNotes.tr,
              maxLines: 3,
              onChanged: (v) => controller.notes.value = v,
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
              label: Tr.reqSaveAndMatch.tr,
              loading: controller.busy.value,
              onPressed: () async {
                final id = await controller.saveAndMatch();
                if (id != null) {
                  AppSnackbar.show(Tr.reqSaved.tr, tone: FeedbackTone.success);
                  unawaited(
                    Get.offNamed<void>(Routes.propertyMatches, arguments: id),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
