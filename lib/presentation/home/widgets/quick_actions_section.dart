import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/permissions/permissions_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// A row of one-tap actions, filtered to what the session can do.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final r = Get.find<PermissionsController>().resolver;
    final text = Theme.of(context).textTheme;

    final actions = <(IconData, String)>[
      if (r.isTravel && r.can(Perm.bookingManage))
        (Icons.flight_takeoff, Tr.homeQaNewBooking.tr),
      if (r.canAny(const [Perm.customerManage, Perm.travellerManage]))
        (Icons.person_add_alt, Tr.homeQaNewCustomer.tr),
      if (r.can(Perm.taskCreate)) (Icons.add_task, Tr.homeQaNewTask.tr),
      if (r.allows(Perm.attendanceSelf, feature: Feature.attendance))
        (Icons.fingerprint, Tr.homeQaCheckIn.tr),
    ];

    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xxs,
              0,
              AppSpacing.xxs,
              AppSpacing.xs,
            ),
            child: Text(Tr.homeQuickActions.tr, style: text.titleMedium),
          ),
          SizedBox(
            height: 108,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, i) => _ActionTile(
                icon: actions[i].$1,
                label: actions[i].$2,
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.brMd,
      child: Container(
        width: 104,
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: AppRadius.brMd,
          border: Border.all(color: c.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: c.primary),
            SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: text.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
