import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/tenant_user.dart';
import '../controllers/users_controller.dart';

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.orgUsers.tr)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<TenantUser>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (v) => v.isEmpty,
            data: (users) => ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final u = users[i];
                return ListTile(
                  leading: AppAvatar(name: u.name),
                  title: Text(u.name),
                  subtitle: Text(
                    u.roles.isEmpty
                        ? u.email
                        : '${u.email} · ${u.roles.join(', ')}',
                  ),
                  trailing: controller.canAssignRoles
                      ? IconButton(
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          onPressed: () => _openRoleAssignment(u),
                        )
                      : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openRoleAssignment(TenantUser user) {
    unawaited(AppBottomSheet.show<void>(_RoleAssignmentSheet(user: user)));
  }
}

class _RoleAssignmentSheet extends StatefulWidget {
  const _RoleAssignmentSheet({required this.user});

  final TenantUser user;

  @override
  State<_RoleAssignmentSheet> createState() => _RoleAssignmentSheetState();
}

class _RoleAssignmentSheetState extends State<_RoleAssignmentSheet> {
  late final Set<String> _selected = widget.user.roles.toSet();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Tr.orgAssignRoles.trParams({'name': widget.user.name}),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          Obx(
            () => Column(
              children: [
                for (final role in controller.roles)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(role.name),
                    value: _selected.contains(role.name),
                    onChanged: (checked) => setState(() {
                      if (checked ?? false) {
                        _selected.add(role.name);
                      } else {
                        _selected.remove(role.name);
                      }
                    }),
                  ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),
          AppButton(
            label: Tr.save.tr,
            loading: _saving,
            onPressed: () async {
              setState(() => _saving = true);
              final ok = await controller.assignRoles(
                widget.user,
                _selected.toList(),
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
