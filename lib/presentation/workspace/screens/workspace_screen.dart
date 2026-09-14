import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/permissions/permissions_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/permissions/can.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';

/// The "More" tab: role-aware access to the common platform. Bottom nav stays
/// travel-focused; everything else is reached here.
class WorkspaceScreen extends StatelessWidget {
  const WorkspaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().user;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(Tr.workspaceTitle.tr)),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          if (user != null)
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  AppAvatar(name: user.name, size: 44),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: text.titleMedium),
                        Text(
                          user.tenant?.name ?? user.email,
                          style: text.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          _Group(Tr.wsSectionWork.tr, [
            _Row(
              Icons.person_outline,
              Tr.wsProfile.tr,
              () => Get.toNamed<void>(Routes.profile),
            ),
            _Row(
              Icons.fingerprint,
              Tr.wsAttendance.tr,
              () => Get.toNamed<void>(Routes.attendance),
              permission: Perm.attendanceSelf,
              feature: Feature.attendance,
            ),
            _Row(
              Icons.event_available_outlined,
              Tr.wsLeave.tr,
              () => Get.toNamed<void>(Routes.leave),
              permission: Perm.leaveRequest,
              feature: Feature.leave,
            ),
            _Row(
              Icons.receipt_long_outlined,
              Tr.wsExpenses.tr,
              () => Get.toNamed<void>(Routes.expenses),
              permission: Perm.expenseSubmit,
              feature: Feature.expenses,
            ),
            _Row(
              Icons.folder_outlined,
              Tr.wsDocuments.tr,
              () => Get.toNamed<void>(Routes.documents),
              permission: Perm.documentView,
              feature: Feature.documents,
            ),
            _Row(
              Icons.calendar_month_outlined,
              Tr.wsHolidays.tr,
              () => Get.toNamed<void>(Routes.holidays),
            ),
          ]),

          if (Get.find<PermissionsController>().isTravel)
            _Group(Tr.wsSectionTravel.tr, [
              _Row(
                Icons.groups_2_outlined,
                Tr.wsTravellers.tr,
                () => Get.toNamed<void>(Routes.travellers),
                permission: Perm.travellerView,
              ),
              _Row(
                Icons.flight_outlined,
                Tr.wsBookings.tr,
                () => Get.toNamed<void>(Routes.bookings),
                permission: Perm.bookingView,
              ),
              _Row(
                Icons.flight_takeoff_outlined,
                Tr.wsDepartures.tr,
                () => Get.toNamed<void>(Routes.departures),
                permission: Perm.bookingView,
              ),
            ]),

          _Group(Tr.wsSectionManage.tr, [
            _Row(
              Icons.groups_outlined,
              Tr.wsTeam.tr,
              () => Get.toNamed<void>(Routes.team),
              permission: Perm.employeeView,
            ),
            _Row(
              Icons.campaign_outlined,
              Tr.navFollowUps.tr,
              () => Get.toNamed<void>(Routes.followUps),
              permission: Perm.followUpManage,
              feature: Feature.crm,
            ),
            _Row(
              Icons.receipt_outlined,
              Tr.wsInvoices.tr,
              () => Get.toNamed<void>(Routes.invoices),
              permission: Perm.invoiceView,
            ),
            _Row(
              Icons.insights_outlined,
              Tr.wsReports.tr,
              () => Get.toNamed<void>(Routes.reports),
              permission: Perm.reportsView,
              feature: Feature.reports,
            ),
            _Row(
              Icons.rule_outlined,
              Tr.wsApprovals.tr,
              () => Get.toNamed<void>(Routes.approvals),
              anyOf: const [Perm.leaveApprove, Perm.expenseApprove],
            ),
            _Row(
              Icons.location_on_outlined,
              Tr.wsOfficeLocation.tr,
              () => Get.toNamed<void>(Routes.officeLocation),
              permission: Perm.attendanceManage,
            ),
          ]),

          _Group(Tr.wsSectionAccount.tr, [
            _Row(
              Icons.settings_outlined,
              Tr.wsSettings.tr,
              () => Get.toNamed<void>(Routes.settings),
            ),
            _Row(Icons.help_outline, Tr.wsHelp.tr, () => _soon(Tr.wsHelp.tr)),
          ]),
        ],
      ),
    );
  }

  static void _soon(String title) =>
      Get.toNamed<void>(Routes.comingSoon, arguments: title);
}

class _Group extends StatelessWidget {
  const _Group(this.title, this.rows);

  final String title;
  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xs,
          ),
          child: AppSectionLabel(title),
        ),
        ...rows,
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
    this.icon,
    this.label,
    this.onTap, {
    this.permission,
    this.feature,
    this.anyOf,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? permission;
  final String? feature;
  final List<String>? anyOf;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final tile = ListTile(
      leading: Icon(icon, color: c.onSurface),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );

    if (anyOf != null) return Can.anyOf(anyOf!, child: tile);
    if (permission != null) {
      return Can(permission!, feature: feature, child: tile);
    }
    return tile;
  }
}
