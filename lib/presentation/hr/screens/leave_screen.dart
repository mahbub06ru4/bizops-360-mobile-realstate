import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/leave_request.dart';
import '../controllers/leave_controller.dart';
import '../hr_display.dart';

class LeaveScreen extends GetView<LeaveController> {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.leaveTitle.tr)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final ok = await Get.toNamed<bool>(Routes.leaveRequest);
          if (ok ?? false) {
            AppSnackbar.show(Tr.leaveSubmitted.tr, tone: FeedbackTone.success);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(Tr.leaveNew.tr),
      ),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xxl + AppSpacing.xl,
          ),
          children: [
            AppSectionLabel(Tr.leaveBalance.tr),
            SizedBox(height: AppSpacing.xs),
            Obx(
              () => AsyncView<List<LeaveBalance>>(
                value: controller.balances.value,
                onRetry: controller.load,
                data: (list) => Row(
                  children: [
                    for (final b in list)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: AppSpacing.sm),
                          child: _BalanceCard(balance: b),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            AppSectionLabel(Tr.leaveMyRequests.tr),
            SizedBox(height: AppSpacing.xs),
            Obx(
              () => AsyncView<List<LeaveRequest>>(
                value: controller.requests.value,
                onRetry: controller.load,
                isEmpty: (l) => l.isEmpty,
                data: (list) => Column(
                  children: [
                    for (final r in list)
                      Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _RequestCard(request: r),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final LeaveBalance balance;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      padding: EdgeInsets.all(AppSpacing.sm),
      child: Column(
        children: [
          Text('${balance.remaining}', style: text.displaySmall),
          Text(balance.type.labelKey.tr, style: text.bodySmall),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final LeaveRequest request;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final range =
        '${DateFormat.MMMd().format(request.from)} – ${DateFormat.MMMd().format(request.to)}';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${request.type.labelKey.tr} · ${Tr.leaveDaysN.trParams({'n': '${request.days}'})}',
                  style: text.titleMedium,
                ),
              ),
              AppStatusChip(
                request.status.labelKey.tr,
                tone: request.status.tone,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(range, style: text.bodySmall),
          SizedBox(height: AppSpacing.xs),
          Text(request.reason, style: text.bodyMedium),
          if (request.decisionNote != null) ...[
            SizedBox(height: AppSpacing.xs),
            Text('“${request.decisionNote!}”', style: text.bodySmall),
          ],
        ],
      ),
    );
  }
}
