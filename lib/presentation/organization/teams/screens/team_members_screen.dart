import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/team.dart';
import '../../../team/employee_display.dart';
import '../controllers/team_members_controller.dart';

class TeamMembersScreen extends GetView<TeamMembersController> {
  const TeamMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.orgTeamMembers.tr)),
      body: Obx(
        () => AsyncView<Team>(
          value: controller.team.value,
          onRetry: controller.load,
          data: (team) => Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: controller.allEmployees.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final employee = controller.allEmployees[i];
                    return Obx(
                      () => CheckboxListTile(
                        value: controller.selectedIds.contains(employee.id),
                        onChanged: (_) => controller.toggle(employee.id),
                        title: Text(employee.name),
                        subtitle: employee.designationName == null
                            ? null
                            : Text(employee.designationName!),
                        secondary: AppStatusChip(
                          employee.status.labelKey.tr,
                          tone: employee.status.tone,
                          dot: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Obx(
                  () => AppButton(
                    label: Tr.save.tr,
                    loading: controller.saving.value,
                    onPressed: () async {
                      final error = await controller.saveMembers();
                      if (error == null) {
                        AppSnackbar.show(
                          Tr.orgSaved.tr,
                          tone: FeedbackTone.success,
                        );
                      } else {
                        AppSnackbar.error(error);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
