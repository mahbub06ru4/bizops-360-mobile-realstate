import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/extensions/money_format.dart';
import '../../../core/localization/translation_keys.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/entities/report_overview.dart';
import '../controllers/reports_controller.dart';

class ReportsScreen extends GetView<ReportsController> {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.reportsTitle.tr)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<ReportOverview>(
            value: controller.state.value,
            onRetry: controller.load,
            data: (o) => ListView(
              padding: EdgeInsets.all(AppSpacing.lg),
              children: [
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisExtent: 96,
                  ),
                  children: [
                    _Kpi(
                      Tr.repRevenue.tr,
                      o.revenueThisMonth.toBdt(decimals: false),
                    ),
                    _Kpi(
                      Tr.repPipeline.tr,
                      o.pipelineValue.toBdt(decimals: false),
                    ),
                    _Kpi(
                      Tr.repOutstanding.tr,
                      o.outstanding.toBdt(decimals: false),
                    ),
                    _Kpi(Tr.repDues.tr, o.customerDues.toBdt(decimals: false)),
                    _Kpi(Tr.repConverted.tr, '${o.convertedThisMonth}'),
                    _Kpi(
                      '${Tr.repVisaApproved.tr} / ${Tr.repVisaInProgress.tr}',
                      '${o.visaApproved} / ${o.visaInProgress}',
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xl),
                AppSectionLabel(Tr.repMonthlyRevenue.tr),
                SizedBox(height: AppSpacing.sm),
                AppCard(child: _BarChart(points: o.monthlyRevenue)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: AppRadius.brMd,
        border: Border.all(color: c.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTypography.mono(c.ink, size: 17, weight: FontWeight.w600),
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: text.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Hand-rolled bar chart — no chart package.
class _BarChart extends StatelessWidget {
  const _BarChart({required this.points});

  final List<MonthlyPoint> points;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final maxValue = points.fold<num>(1, (m, p) => p.value > m ? p.value : m);

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final p in points)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    (p.value / 1000).round().toString(),
                    style: text.bodySmall,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    height: 110 * (p.value / maxValue),
                    decoration: BoxDecoration(
                      color: c.brand,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(p.label, style: text.bodySmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
