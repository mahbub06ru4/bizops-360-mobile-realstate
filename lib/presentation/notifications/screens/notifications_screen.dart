import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/app_notification.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Tr.notificationsTitle.tr),
        actions: [
          TextButton(
            onPressed: controller.markAllRead,
            child: Text(Tr.markAllRead.tr),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<AppNotification>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (list) => list.isEmpty,
            empty: AppEmptyState(
              icon: Icons.notifications_none,
              message: Tr.notificationsEmpty.tr,
            ),
            data: (list) => _List(
              groups: controller.groupsFrom(list),
              onTap: controller.open,
            ),
          ),
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.groups, required this.onTap});

  final List<NotificationGroup> groups;
  final ValueChanged<AppNotification> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: AppSpacing.xxl),
      children: [
        for (final group in groups) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSectionLabel(group.label.tr),
          ),
          for (final n in group.items)
            _Tile(notification: n, onTap: () => onTap(n)),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  IconData get _icon => switch (notification.kind) {
    NotificationKind.task => Icons.check_circle_outline,
    NotificationKind.leave => Icons.event_available_outlined,
    NotificationKind.payment => Icons.payments_outlined,
    NotificationKind.followUp => Icons.campaign_outlined,
    NotificationKind.visaDeadline => Icons.schedule_outlined,
    NotificationKind.documentExpiry => Icons.description_outlined,
    NotificationKind.general => Icons.notifications_none,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: notification.read ? null : c.brandSoft.withValues(alpha: 0.35),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icon, size: 20, color: c.inkMuted),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: notification.read
                          ? FontWeight.w500
                          : FontWeight.w700,
                    ),
                  ),
                  Text(notification.body, style: text.bodyMedium),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    DateFormat.jm().format(notification.createdAt),
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
            if (!notification.read)
              Padding(
                padding: EdgeInsets.only(top: AppSpacing.xs),
                child: CircleAvatar(radius: 4, backgroundColor: c.signal),
              ),
          ],
        ),
      ),
    );
  }
}
