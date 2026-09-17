import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/permissions/can.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/routing/app_routes.dart';
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
      floatingActionButton: Can(
        Perm.employeeCreate,
        child: FloatingActionButton(
          onPressed: () => Get.toNamed<void>(Routes.employeeForm),
          child: const Icon(Icons.person_add_alt_1_outlined),
        ),
      ),
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
              onChanged: controller.onQueryChanged,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: Obx(() {
                final items = controller.paging.items;
                final firstLoad =
                    items.isEmpty && controller.paging.loadingMore.value;
                final firstLoadError =
                    items.isEmpty &&
                    !controller.paging.loadingMore.value &&
                    controller.paging.loadMoreError.value != null;

                if (firstLoad) return const AppLoader();
                if (firstLoadError) {
                  return AppErrorState(
                    message: controller.paging.loadMoreError.value,
                    onRetry: controller.load,
                  );
                }
                if (items.isEmpty) {
                  return ListView(
                    children: [
                      SizedBox(height: AppSpacing.xxl),
                      const AppEmptyState(),
                    ],
                  );
                }
                return ListView.separated(
                  itemCount: items.length + 1,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    if (i == items.length) {
                      return AppPagination(controller: controller.paging);
                    }
                    return _EmployeeRow(items[i]);
                  },
                );
              }),
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
      employee.designationName,
      employee.departmentName,
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
      onTap: () =>
          Get.toNamed<void>(Routes.employeeDetail, arguments: employee.id),
    );
  }
}
