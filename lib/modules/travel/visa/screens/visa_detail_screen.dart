import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/visa_application.dart';
import '../controllers/visa_detail_controller.dart';
import '../visa_display.dart';

class VisaDetailScreen extends GetView<VisaDetailController> {
  const VisaDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.state.value.valueOrNull?.travellerName ?? Tr.navVisa.tr,
          ),
        ),
      ),
      body: Obx(
        () => AsyncView<VisaApplication>(
          value: controller.state.value,
          onRetry: controller.reload,
          data: (a) => _body(context, a),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final a = controller.state.value.valueOrNull;
        if (a == null) return const SizedBox.shrink();
        return _ActionBar(app: a, busy: controller.busy.value);
      }),
    );
  }

  Widget _body(BuildContext context, VisaApplication a) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${a.country} · ${a.category}',
                style: text.titleMedium,
              ),
            ),
            AppStatusChip(a.stage.labelKey.tr, tone: a.stage.tone),
          ],
        ),
        if (a.submittedAt != null)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xxs),
            child: Text(
              '${Tr.visaSubmittedOn.tr}: ${DateFormat.yMMMd().format(a.submittedAt!)}',
              style: text.bodySmall,
            ),
          ),
        if (a.decisionAt != null)
          Text(
            '${Tr.visaDecidedOn.tr}: ${DateFormat.yMMMd().format(a.decisionAt!)}',
            style: text.bodySmall,
          ),
        SizedBox(height: AppSpacing.lg),
        AppSectionLabel(
          '${Tr.visaDocsChecklist.tr} · ${a.docsCollected}/${a.docs.length}',
        ),
        SizedBox(height: AppSpacing.xs),
        LinearProgressIndicator(
          value: a.docProgress,
          minHeight: 6,
          borderRadius: BorderRadius.circular(999),
        ),
        Obx(() {
          final err = controller.actionError.value;
          if (err == null) return const SizedBox.shrink();
          return Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              err,
              style: text.bodySmall?.copyWith(
                color: context.colors.criticalInk,
              ),
            ),
          );
        }),
        SizedBox(height: AppSpacing.xs),
        for (final doc in a.docs)
          CheckboxListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: doc.collected,
            onChanged: a.isDecided
                ? null
                : (_) => controller.toggleDoc(doc.name),
            title: Text(doc.name),
          ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.app, required this.busy});

  final VisaApplication app;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final controller = Get.find<VisaDetailController>();

    Widget bar(Widget child) =>
        SafeArea(minimum: EdgeInsets.all(AppSpacing.lg), child: child);

    switch (app.stage) {
      case VisaStage.caseOpened:
      case VisaStage.docsRequired:
      case VisaStage.docsCollected:
        return bar(
          AppButton(
            label: app.allDocsCollected
                ? Tr.visaSubmit.tr
                : Tr.visaSubmitBlocked.tr,
            icon: Icons.send,
            loading: busy,
            onPressed: app.allDocsCollected ? controller.submit : null,
          ),
        );
      case VisaStage.submitted:
        return bar(
          AppButton(
            label: Tr.visaStartProcessing.tr,
            loading: busy,
            onPressed: () => controller.moveStage(VisaStage.processing),
          ),
        );
      case VisaStage.processing:
        return bar(
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: Tr.visaReject.tr,
                  variant: AppButtonVariant.secondary,
                  loading: busy,
                  onPressed: () => controller.decide(approved: false),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: Tr.visaApprove.tr,
                  loading: busy,
                  onPressed: () => controller.decide(approved: true),
                ),
              ),
            ],
          ),
        );
      case VisaStage.approved:
      case VisaStage.rejected:
        return bar(
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                app.stage == VisaStage.approved
                    ? Icons.check_circle
                    : Icons.cancel,
                color: app.stage == VisaStage.approved ? c.brand : c.critical,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                app.stage.labelKey.tr,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        );
    }
  }
}
