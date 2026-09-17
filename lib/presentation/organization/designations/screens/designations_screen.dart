import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../application/permissions/permissions_controller.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/designation.dart';
import '../controllers/designations_controller.dart';

class DesignationsScreen extends GetView<DesignationsController> {
  const DesignationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.orgDesignations.tr)),
      floatingActionButton: Can(
        Perm.designationCreate,
        child: FloatingActionButton(
          onPressed: () => _openForm(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<Designation>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (v) => v.isEmpty,
            data: (designations) => ListView.separated(
              itemCount: designations.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final d = designations[i];
                return ListTile(
                  title: Text(d.title),
                  subtitle: d.departmentName == null
                      ? null
                      : Text(d.departmentName!),
                  trailing: Can.anyOf(
                    const [Perm.designationManage, Perm.designationDelete],
                    child: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(context, existing: d);
                        if (v == 'delete') unawaited(controller.delete(d));
                      },
                      itemBuilder: (_) {
                        final perms = Get.find<PermissionsController>();
                        return [
                          if (perms.can(Perm.designationManage))
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(Tr.edit.tr),
                            ),
                          if (perms.can(Perm.designationDelete))
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

  void _openForm(BuildContext context, {Designation? existing}) {
    unawaited(AppBottomSheet.show<void>(_DesignationForm(existing: existing)));
  }
}

class _DesignationForm extends StatefulWidget {
  const _DesignationForm({this.existing});

  final Designation? existing;

  @override
  State<_DesignationForm> createState() => _DesignationFormState();
}

class _DesignationFormState extends State<_DesignationForm> {
  late final _title = TextEditingController(text: widget.existing?.title);
  late final _rank = TextEditingController(
    text: widget.existing?.rank?.toString(),
  );
  String? _departmentId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _departmentId = widget.existing?.departmentId;
  }

  @override
  void dispose() {
    _title.dispose();
    _rank.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DesignationsController>();

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
                ? Tr.orgAddDesignation.tr
                : Tr.orgEditDesignation.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: Tr.orgTitle.tr, controller: _title),
          SizedBox(height: AppSpacing.md),
          Obx(
            () => AppDropdown<String>(
              label: Tr.empDepartment.tr,
              value: _departmentId,
              items: [
                for (final d in controller.departments)
                  AppDropdownItem(d.id, d.name),
              ],
              onChanged: (v) => setState(() => _departmentId = v),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(
            label: Tr.orgRank.tr,
            controller: _rank,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            label: Tr.save.tr,
            loading: _saving,
            onPressed: () async {
              setState(() => _saving = true);
              final ok = await controller.save(
                DesignationInput(
                  title: _title.text.trim(),
                  departmentId: _departmentId,
                  rank: int.tryParse(_rank.text.trim()),
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
