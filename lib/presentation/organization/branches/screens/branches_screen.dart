import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../application/permissions/permissions_controller.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/branch.dart';
import '../controllers/branches_controller.dart';

class BranchesScreen extends GetView<BranchesController> {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.orgBranches.tr)),
      floatingActionButton: Can(
        Perm.branchCreate,
        child: FloatingActionButton(
          onPressed: () => _openForm(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<Branch>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (v) => v.isEmpty,
            data: (branches) => ListView.separated(
              itemCount: branches.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final b = branches[i];
                return ListTile(
                  title: Text(b.name),
                  subtitle: Text(b.code),
                  trailing: Can.anyOf(
                    const [Perm.branchManage, Perm.branchDelete],
                    child: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(context, existing: b);
                        if (v == 'delete') unawaited(controller.delete(b));
                      },
                      itemBuilder: (_) {
                        final perms = Get.find<PermissionsController>();
                        return [
                          if (perms.can(Perm.branchManage))
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(Tr.edit.tr),
                            ),
                          if (perms.can(Perm.branchDelete))
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

  void _openForm(BuildContext context, {Branch? existing}) {
    unawaited(AppBottomSheet.show<void>(_BranchForm(existing: existing)));
  }
}

class _BranchForm extends StatefulWidget {
  const _BranchForm({this.existing});

  final Branch? existing;

  @override
  State<_BranchForm> createState() => _BranchFormState();
}

class _BranchFormState extends State<_BranchForm> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _code = TextEditingController(text: widget.existing?.code);
  late final _address = TextEditingController(text: widget.existing?.address);
  bool _isHeadOffice = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _isHeadOffice = widget.existing?.isHeadOffice ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? Tr.orgAddBranch.tr : Tr.orgEditBranch.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: Tr.orgName.tr, controller: _name),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: Tr.orgCode.tr, controller: _code),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: Tr.orgAddress.tr, controller: _address),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(Tr.orgHeadOffice.tr),
            value: _isHeadOffice,
            onChanged: (v) => setState(() => _isHeadOffice = v),
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            label: Tr.save.tr,
            loading: _saving,
            onPressed: () async {
              setState(() => _saving = true);
              final ok = await Get.find<BranchesController>().save(
                BranchInput(
                  name: _name.text.trim(),
                  code: _code.text.trim(),
                  address: _address.text.trim().isEmpty
                      ? null
                      : _address.text.trim(),
                  isHeadOffice: _isHeadOffice,
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
