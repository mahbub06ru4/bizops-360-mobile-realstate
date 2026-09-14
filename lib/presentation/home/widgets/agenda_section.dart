import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import 'dashboard_section.dart';

/// A short list of dated items (tasks, follow-ups) on the Home dashboard.
/// Purely presentational — callers feed it live data from their own
/// controller (see `_TasksPreview` / `_FollowUpsPreview` in `home_screen.dart`).
class AgendaItem {
  const AgendaItem(this.title, this.meta, {this.tone = ChipTone.neutral});

  final String title;
  final String meta;
  final ChipTone tone;
}

class AgendaSection extends StatelessWidget {
  const AgendaSection({
    required this.title,
    required this.items,
    this.onViewAll,
    super.key,
  });

  final String title;
  final List<AgendaItem> items;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return DashboardSection(
      title: title,
      onViewAll: items.isEmpty ? null : onViewAll,
      trailing: items.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.only(right: AppSpacing.sm),
              child: AppBadge(count: items.length),
            ),
      child: items.isEmpty
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                Tr.homeNothingToday.tr,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _AgendaTile(items[i]),
                ],
              ],
            ),
    );
  }
}

class _AgendaTile extends StatelessWidget {
  const _AgendaTile(this.item);

  final AgendaItem item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(child: Text(item.title, style: text.bodyLarge)),
          SizedBox(width: AppSpacing.sm),
          AppStatusChip(item.meta, tone: item.tone, dot: false),
        ],
      ),
    );
  }
}
