import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../application/permissions/permissions_controller.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/department.dart';
import '../controllers/departments_controller.dart';

class DepartmentsScreen extends GetView<DepartmentsController> {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.orgDepartments.tr)),
      floatingActionButton: Can(
        Perm.departmentCreate,
        child: FloatingActionButton(
          onPressed: () => _openForm(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<Department>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (v) => v.isEmpty,
            data: (departments) => ListView.separated(
              itemCount: departments.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = departments[i];
                return ListTile(
                  title: Text(d.name),
                  subtitle: Text(
                    [d.code, d.branchName].whereType<String>().join(' · '),
                  ),
                  trailing: Can.anyOf(
                    const [Perm.departmentManage, Perm.departmentDelete],
                    child: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(context, existing: d);
                        if (v == 'delete') unawaited(controller.delete(d));
                      },
                      itemBuilder: (_) {
                        final perms = Get.find<PermissionsController>();
                        return [
                          if (perms.can(Perm.departmentManage))
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(Tr.edit.tr),
                            ),
                          if (perms.can(Perm.departmentDelete))
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(Tr.delete.tr),
                            ),
                        ];
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openForm(BuildContext context, {Department? existing}) {
    unawaited(AppBottomSheet.show<void>(_DepartmentForm(existing: existing)));
  }
}

class _DepartmentForm extends StatefulWidget {
  const _DepartmentForm({this.existing});

  final Department? existing;

  @override
  State<_DepartmentForm> createState() => _DepartmentFormState();
}

class _DepartmentFormState extends State<_DepartmentForm> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _code = TextEditingController(text: widget.existing?.code);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  String? _branchId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _branchId = widget.existing?.branchId;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DepartmentsController>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null
                ? Tr.orgAddDepartment.tr
                : Tr.orgEditDepartment.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: Tr.orgName.tr, controller: _name),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: Tr.orgCode.tr, controller: _code),
          SizedBox(height: AppSpacing.md),
          Obx(
            () => AppDropdown<String>(
              label: Tr.empBranch.tr,
              value: _branchId,
              items: [
                for (final b in controller.branches)
                  AppDropdownItem(b.id, b.name),
              ],
              onChanged: (v) => setState(() => _branchId = v),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: Tr.orgDescription.tr,
            controller: _description,
            maxLines: 2,
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            label: Tr.save.tr,
            loading: _saving,
            onPressed: () async {
              setState(() => _saving = true);
              final ok = await controller.save(
                DepartmentInput(
                  name: _name.text.trim(),
                  code: _code.text.trim(),
                  branchId: _branchId,
                  description: _description.text.trim().isEmpty
                      ? null
                      : _description.text.trim(),
                ),
                existing: widget.existing,
              );
              if (!mounted) return;
              setState(() => _saving = false);
              if (ok) Get.back<void>();
            },
          ),
        ],
      ),
    );
  }
}
