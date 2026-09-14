import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/entities/site_visit.dart';
import '../../pipeline_display.dart';
import '../controllers/site_visits_controller.dart';

class SiteVisitsScreen extends StatefulWidget {
  const SiteVisitsScreen({super.key});

  @override
  State<SiteVisitsScreen> createState() => _SiteVisitsScreenState();
}

class _SiteVisitsScreenState extends State<SiteVisitsScreen> {
  final controller = Get.find<SiteVisitsController>();
  var _autoOpened = false;

  @override
  Widget build(BuildContext context) {
    // Reached from a project's unit list ("Schedule visit") — open the
    // schedule sheet pre-filled with that project/unit once the lookups
    // (leads, projects) have loaded.
    if (!_autoOpened && controller.prefillProjectId != null) {
      _autoOpened = true;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _showScheduleSheet(context),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(Tr.svTitle.tr)),
      floatingActionButton: Can(
        Perm.siteVisitManage,
        child: FloatingActionButton.extended(
          onPressed: () => _showScheduleSheet(context),
          icon: const Icon(Icons.add),
          label: Text(Tr.svSchedule.tr),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<SiteVisit>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (l) => l.isEmpty,
            empty: ListView(
              children: [
                SizedBox(height: AppSpacing.xxl),
                AppEmptyState(message: Tr.svEmpty.tr),
              ],
            ),
            data: (items) => ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: items.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _VisitCard(visit: items[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showScheduleSheet(BuildContext context) {
    return AppBottomSheet.show<void>(_ScheduleForm(controller: controller));
  }
}

class _VisitCard extends StatelessWidget {
  const _VisitCard({required this.visit});

  final SiteVisit visit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final controller = Get.find<SiteVisitsController>();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(visit.leadName, style: text.titleMedium)),
              AppStatusChip(visit.status.labelKey.tr, tone: visit.status.tone),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            [
              visit.projectTitle,
              visit.unitName,
            ].whereType<String>().join(' · '),
            style: text.bodyMedium,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            DateFormat.yMMMEd().add_jm().format(visit.scheduledAt),
            style: text.bodySmall,
          ),
          if (visit.feedback != null && visit.feedback!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.xs),
            Text(visit.feedback!, style: text.bodySmall),
          ],
          if (visit.status == SiteVisitStatus.scheduled) ...[
            SizedBox(height: AppSpacing.sm),
            Can(
              Perm.siteVisitManage,
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: Tr.svComplete.tr,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => controller.complete(visit.id),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: Tr.svCancel.tr,
                      variant: AppButtonVariant.text,
                      onPressed: () => controller.cancel(visit.id),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleForm extends StatefulWidget {
  const _ScheduleForm({required this.controller});

  final SiteVisitsController controller;

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  Customer? _lead;
  RealEstateProject? _project;
  String? _unitId;
  String? _unitName;
  DateTime _at = DateTime.now().add(const Duration(days: 1));
  var _prefillApplied = false;

  void _applyPrefill() {
    final c = widget.controller;
    if (_prefillApplied || c.prefillProjectId == null) return;
    final project = c.projects
        .where((p) => p.id == c.prefillProjectId)
        .firstOrNull;
    if (project == null) return;
    _prefillApplied = true;
    _project = project;
    _unitId = c.prefillUnitId;
    _unitName = c.prefillUnitName;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    _applyPrefill();
    return Obx(
      () => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Tr.svSchedule.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppSpacing.md),
            AppDropdown<Customer>(
              label: Tr.svLead.tr,
              value: _lead,
              items: [
                for (final l in c.leads) AppDropdownItem<Customer>(l, l.name),
              ],
              onChanged: (v) => setState(() => _lead = v),
            ),
            SizedBox(height: AppSpacing.md),
            AppDropdown<RealEstateProject>(
              label: Tr.svProject.tr,
              value: _project,
              items: [
                for (final p in c.projects)
                  AppDropdownItem<RealEstateProject>(p, p.title),
              ],
              onChanged: (v) => setState(() {
                _project = v;
                _unitId = null;
                _unitName = null;
              }),
            ),
            if (_project != null && _project!.unitCount > 0) ...[
              SizedBox(height: AppSpacing.md),
              AppDropdown<String>(
                label: Tr.svUnit.tr,
                value: _unitId,
                items: [
                  for (final b in _project!.buildings)
                    for (final u in b.units)
                      AppDropdownItem<String>(u.id, u.unitNumber),
                ],
                onChanged: (v) => setState(() {
                  _unitId = v;
                  _unitName = _project!.buildings
                      .expand((b) => b.units)
                      .where((u) => u.id == v)
                      .firstOrNull
                      ?.unitNumber;
                }),
              ),
            ],
            SizedBox(height: AppSpacing.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(Tr.svScheduledAt.tr),
              subtitle: Text(DateFormat.yMMMEd().add_jm().format(_at)),
              trailing: const Icon(Icons.edit_calendar_outlined),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _at,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date == null || !context.mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_at),
                );
                if (time == null) return;
                setState(
                  () => _at = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    time.hour,
                    time.minute,
                  ),
                );
              },
            ),
            if (c.error.value != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                c.error.value!,
                style: TextStyle(color: context.colors.criticalInk),
              ),
            ],
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: Tr.svSchedule.tr,
              loading: c.busy.value,
              onPressed: _lead == null || _project == null
                  ? null
                  : () async {
                      final ok = await c.schedule(
                        lead: _lead!,
                        project: _project!,
                        unitId: _unitId,
                        unitName: _unitName,
                        scheduledAt: _at,
                      );
                      if (ok && context.mounted) {
                        Get.back<void>();
                        AppSnackbar.show(
                          Tr.svScheduled.tr,
                          tone: FeedbackTone.success,
                        );
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
