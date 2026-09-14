import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../application/auth/auth_controller.dart';
import '../../../application/navigation/shell_controller.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/permissions/can.dart';
import '../../../core/permissions/permissions.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/follow_up.dart';
import '../../../domain/entities/task_item.dart';
import '../../../modules/travel/dashboard/pending_visa_docs_section.dart';
import '../../../modules/travel/dashboard/ticket_tasks_section.dart';
import '../../../modules/travel/dashboard/visa_summary_section.dart';
import '../../crm/controllers/follow_ups_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../tasks/controllers/tasks_controller.dart';
import '../widgets/agenda_section.dart';
import '../widgets/quick_actions_section.dart';

/// The operational travel dashboard. A greeting header over a stack of
/// permission-gated [DashboardSection]s — compose, don't grow a build method.
///
/// Sections read the same live controllers/repositories their full screens
/// use (all registered permanent by `ShellBinding`) — no dashboard-only data.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greetingKey() {
    final h = DateTime.now().hour;
    if (h < 12) return Tr.greetingMorning;
    if (h < 17) return Tr.greetingAfternoon;
    return Tr.greetingEvening;
  }

  @override
  Widget build(BuildContext context) {
    final user = Get.find<AuthController>().user;
    final text = Theme.of(context).textTheme;
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppSpacing.lg,
        toolbarHeight: 72,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_greetingKey().tr}, $firstName',
              style: text.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (user?.tenant != null)
              Text(
                user!.tenant!.name,
                style: text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Get.toNamed<void>(Routes.notifications),
            icon: Obx(
              () => AppBadge(
                count: Get.find<NotificationsController>().unreadCount,
                child: const Icon(Icons.notifications_none),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (Get.isRegistered<TasksController>()) {
            await Get.find<TasksController>().load();
          }
          if (Get.isRegistered<FollowUpsController>()) {
            await Get.find<FollowUpsController>().load();
          }
          if (Get.isRegistered<NotificationsController>()) {
            await Get.find<NotificationsController>().load();
          }
        },
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            const QuickActionsSection(),
            const Can(
              Perm.visaView,
              feature: Feature.travelVisa,
              travelOnly: true,
              child: VisaSummarySection(),
            ),
            const Can(
              Perm.visaView,
              feature: Feature.travelVisa,
              travelOnly: true,
              child: PendingVisaDocsSection(),
            ),
            const Can(
              Perm.bookingView,
              feature: Feature.travelBookings,
              travelOnly: true,
              child: TicketTasksSection(),
            ),
            const Can(
              Perm.followUpManage,
              feature: Feature.crm,
              child: _FollowUpsPreview(),
            ),
            const Can(
              Perm.taskView,
              feature: Feature.tasks,
              child: _TasksPreview(),
            ),
          ],
        ),
      ),
    );
  }
}

/// My-tasks preview — reads the same [TasksController] the Tasks tab uses.
class _TasksPreview extends StatelessWidget {
  const _TasksPreview();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TasksController>()) return const SizedBox.shrink();
    final controller = Get.find<TasksController>();

    return Obx(() {
      final all = controller.state.value.valueOrNull ?? const <TaskItem>[];
      final open = all.where((t) => !t.isDone).toList()
        ..sort((a, b) {
          final ad = a.dueDate, bd = b.dueDate;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return ad.compareTo(bd);
        });
      final preview = open.take(3).toList();

      return AgendaSection(
        title: Tr.homeMyTasks.tr,
        items: [
          for (final t in preview)
            AgendaItem(
              t.title,
              t.isOverdue
                  ? Tr.overdue.tr
                  : (t.isDueToday() ? Tr.today.tr : Tr.upcoming.tr),
              tone: t.isOverdue ? ChipTone.critical : ChipTone.brand,
            ),
        ],
        onViewAll: () =>
            Get.find<ShellController>().selectTab(ShellTabId.tasks),
      );
    });
  }
}

/// Follow-ups preview — reads the same [FollowUpsController] the Follow-ups
/// screen uses.
class _FollowUpsPreview extends StatelessWidget {
  const _FollowUpsPreview();

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<FollowUpsController>()) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<FollowUpsController>();

    return Obx(() {
      final all = controller.state.value.valueOrNull ?? const <FollowUp>[];
      final open = all.where((f) => !f.done).toList()
        ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
      final preview = open.take(3).toList();

      return AgendaSection(
        title: Tr.homeFollowUps.tr,
        items: [
          for (final f in preview)
            AgendaItem(
              f.customerName,
              f.isOverdue
                  ? Tr.overdue.tr
                  : (f.isDueToday() ? Tr.today.tr : Tr.upcoming.tr),
              tone: f.isOverdue ? ChipTone.critical : ChipTone.brand,
            ),
        ],
        onViewAll: () => Get.toNamed<void>(Routes.followUps),
      );
    });
  }
}
