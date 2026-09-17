import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../application/permissions/permissions_controller.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/team.dart';
import '../controllers/teams_controller.dart';

class TeamsScreen extends GetView<TeamsController> {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.orgTeams.tr)),
      floatingActionButton: Can(
        Perm.teamCreate,
        child: FloatingActionButton(
          onPressed: () => _openForm(context),
          child: const Icon(Icons.add),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<Team>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (v) => v.isEmpty,
            data: (teams) => ListView.separated(
              itemCount: teams.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = teams[i];
                return ListTile(
                  title: Text(t.name),
                  subtitle: Text(
                    Tr.orgMembersCount.trParams({
                      'count': t.membersCount.toString(),
                    }),
                  ),
                  onTap: () =>
                      Get.toNamed<void>(Routes.teamMembers, arguments: t.id),
                  trailing: Can.anyOf(
                    const [Perm.teamManage, Perm.teamDelete],
                    child: PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') _openForm(context, existing: t);
                        if (v == 'delete') unawaited(controller.delete(t));
                      },
                      itemBuilder: (_) {
                        final perms = Get.find<PermissionsController>();
                        return [
                          if (perms.can(Perm.teamManage))
                            PopupMenuItem(
                              value: 'edit',
                              child: Text(Tr.edit.tr),
                            ),
                          if (perms.can(Perm.teamDelete))
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

  void _openForm(BuildContext context, {Team? existing}) {
    unawaited(AppBottomSheet.show<void>(_TeamForm(existing: existing)));
  }
}

class _TeamForm extends StatefulWidget {
  const _TeamForm({this.existing});

  final Team? existing;

  @override
  State<_TeamForm> createState() => _TeamFormState();
}

class _TeamFormState extends State<_TeamForm> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
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
            widget.existing == null ? Tr.orgAddTeam.tr : Tr.orgEditTeam.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: AppSpacing.md),
          AppTextField(label: Tr.orgName.tr, controller: _name),
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
              final ok = await Get.find<TeamsController>().save(
                TeamInput(
                  name: _name.text.trim(),
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
