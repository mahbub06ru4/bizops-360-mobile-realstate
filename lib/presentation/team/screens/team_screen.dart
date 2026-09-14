import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/employee.dart';
import '../controllers/team_controller.dart';
import '../employee_display.dart';

class TeamScreen extends GetView<TeamController> {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.teamTitle.tr)),
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
              hint: Tr.teamSearch.tr,
              onChanged: (v) => controller.query.value = v,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: Obx(
                () => AsyncView<List<Employee>>(
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
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) => _EmployeeRow(list[i]),
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

class _EmployeeRow extends StatelessWidget {
  const _EmployeeRow(this.employee);

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final subtitle = [
      employee.designation,
      employee.department,
    ].whereType<String>().join(' · ');

    return ListTile(
      leading: AppAvatar(name: employee.name),
      title: Text(employee.name),
      subtitle: subtitle.isEmpty ? null : Text(subtitle, style: text.bodySmall),
      trailing: AppStatusChip(
        employee.status.labelKey.tr,
        tone: employee.status.tone,
        dot: false,
      ),
    );
  }
}
