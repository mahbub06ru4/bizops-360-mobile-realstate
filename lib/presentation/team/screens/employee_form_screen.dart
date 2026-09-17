import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../controllers/employee_form_controller.dart';

class EmployeeFormScreen extends GetView<EmployeeFormController> {
  const EmployeeFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEdit ? Tr.empEditTitle.tr : Tr.empCreateTitle.tr,
        ),
      ),
      body: Obx(
        () => AsyncView<EmployeeFormLookups>(
          value: controller.lookups.value,
          onRetry: controller.loadLookups,
          data: (lookups) => _Form(lookups: lookups),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  const _Form({required this.lookups});

  final EmployeeFormLookups lookups;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  late final controller = Get.find<EmployeeFormController>();
  late final _employeeCode = TextEditingController(
    text: controller.employeeCode.value,
  );
  late final _firstName = TextEditingController(
    text: controller.firstName.value,
  );
  late final _lastName = TextEditingController(text: controller.lastName.value);
  late final _email = TextEditingController(text: controller.email.value);
  late final _phone = TextEditingController(text: controller.phone.value);

  @override
  void dispose() {
    _employeeCode.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lookups = widget.lookups;

    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg),
      children: [
        Obx(
          () => AppTextField(
            label: Tr.empCode.tr,
            controller: _employeeCode,
            errorText: controller.validation.value?.forField('employee_code'),
            onChanged: (v) => controller.employeeCode.value = v,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(
          () => AppTextField(
            label: Tr.empFirstName.tr,
            controller: _firstName,
            errorText: controller.validation.value?.forField('first_name'),
            onChanged: (v) => controller.firstName.value = v,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(
          () => AppTextField(
            label: Tr.empLastName.tr,
            controller: _lastName,
            errorText: controller.validation.value?.forField('last_name'),
            onChanged: (v) => controller.lastName.value = v,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(
          () => AppTextField(
            label: Tr.empEmail.tr,
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            errorText: controller.validation.value?.forField('email'),
            onChanged: (v) => controller.email.value = v,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(
          () => AppTextField(
            label: Tr.empPhone.tr,
            controller: _phone,
            keyboardType: TextInputType.phone,
            errorText: controller.validation.value?.forField('phone'),
            onChanged: (v) => controller.phone.value = v,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(
          () => InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: controller.hireDate.value,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) controller.hireDate.value = picked;
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: Tr.empHireDate.tr,
                suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                errorText: controller.validation.value?.forField('hire_date'),
              ),
              child: Text(DateFormat.yMMMd().format(controller.hireDate.value)),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(
          () => AppDropdown<String>(
            label: Tr.empBranch.tr,
            value: controller.branchId.value,
            items: [
              for (final b in lookups.branches) AppDropdownItem(b.id, b.name),
            ],
            onChanged: (v) => controller.branchId.value = v,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(
          () => AppDropdown<String>(
            label: Tr.empDepartment.tr,
            value: controller.departmentId.value,
            items: [
              for (final d in lookups.departments)
                AppDropdownItem(d.id, d.name),
            ],
            onChanged: (v) => controller.departmentId.value = v,
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Obx(
          () => AppDropdown<String>(
            label: Tr.empDesignation.tr,
            value: controller.designationId.value,
            items: [
              for (final d in lookups.designations)
                AppDropdownItem(d.id, d.title),
            ],
            onChanged: (v) => controller.designationId.value = v,
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        Obx(
          () => AppButton(
            label: Tr.save.tr,
            loading: controller.saving.value,
            onPressed: () async {
              if (await controller.save()) Get.back<void>();
            },
          ),
        ),
      ],
    );
  }
}
