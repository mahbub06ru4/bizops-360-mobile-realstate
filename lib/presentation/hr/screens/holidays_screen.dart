import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/holiday.dart';
import '../controllers/holidays_controller.dart';

class HolidaysScreen extends GetView<HolidaysController> {
  const HolidaysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.holidaysTitle.tr)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<HolidayEntry>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (l) => l.isEmpty,
            empty: AppEmptyState(message: Tr.holidaysEmpty.tr),
            data: (_) {
              final upcoming = controller.upcoming;
              final past = controller.past;
              return ListView(
                padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                children: [
                  if (upcoming.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: AppSectionLabel(Tr.holidaysUpcoming.tr),
                    ),
                    for (final h in upcoming) _Row(holiday: h),
                  ],
                  if (past.isNotEmpty) ...[
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: AppSectionLabel(Tr.holidaysPast.tr),
                    ),
                    for (final h in past) _Row(holiday: h, past: true),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.holiday, this.past = false});

  final HolidayEntry holiday;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return ListTile(
      leading: Icon(Icons.event_outlined, color: past ? c.inkFaint : c.brand),
      title: Text(
        holiday.name,
        style: past
            ? text.bodyLarge?.copyWith(color: c.inkFaint)
            : text.bodyLarge,
      ),
      trailing: Text(
        DateFormat.yMMMEd().format(holiday.date),
        style: text.bodySmall,
      ),
    );
  }
}
