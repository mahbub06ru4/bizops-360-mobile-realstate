import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/permissions/can.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/employee.dart';
import '../controllers/employee_detail_controller.dart';
import '../employee_display.dart';

class EmployeeDetailScreen extends GetView<EmployeeDetailController> {
  const EmployeeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.empDetailTitle.tr),
        actions: [
          Obx(() {
            final employee = controller.state.value.valueOrNull;
            if (employee == null) return const SizedBox.shrink();
            return Can(
              Perm.employeeManage,
              child: IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    Get.toNamed<void>(Routes.employeeForm, arguments: employee),
              ),
            );
          }),
        ],
      ),
      body: Obx(
        () => AsyncView<Employee>(
          value: controller.state.value,
          onRetry: controller.load,
          data: (employee) => _Body(employee: employee),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmployeeDetailController>();
    final text = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: controller.load,
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              AppAvatar(name: employee.name, size: 56),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(employee.name, style: text.titleLarge),
                    Text(employee.employeeCode, style: text.bodySmall),
                  ],
                ),
              ),
              AppStatusChip(
                employee.status.labelKey.tr,
                tone: employee.status.tone,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(Tr.empEmail.tr, employee.email ?? '—'),
                _InfoRow(Tr.empPhone.tr, employee.phone ?? '—'),
                _InfoRow(
                  Tr.empHireDate.tr,
                  employee.hireDate == null
                      ? '—'
                      : '${employee.hireDate!.year}-'
                            '${employee.hireDate!.month.toString().padLeft(2, '0')}-'
                            '${employee.hireDate!.day.toString().padLeft(2, '0')}',
                ),
                _InfoRow(Tr.empBranch.tr, employee.branchName ?? '—'),
                _InfoRow(Tr.empDepartment.tr, employee.departmentName ?? '—'),
                _InfoRow(Tr.empDesignation.tr, employee.designationName ?? '—'),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          if (employee.status != EmploymentStatus.terminated)
            Can(
              Perm.employeeTerminate,
              child: Obx(
                () => AppButton(
                  label: Tr.empTerminate.tr,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.person_off_outlined,
                  loading: controller.terminating.value,
                  onPressed: () async {
                    await controller.terminate();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: text.bodySmall)),
          Expanded(child: Text(value, style: text.bodyMedium)),
        ],
      ),
    );
  }
}
