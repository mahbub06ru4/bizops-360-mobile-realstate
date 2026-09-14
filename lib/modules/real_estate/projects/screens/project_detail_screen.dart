import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/money_format.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/building.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/entities/unit.dart';
import '../controllers/project_detail_controller.dart';
import '../project_display.dart';

/// Shared seller + buyer view of a project. Every viewer sees the same
/// structure (location, land/units, amenities, pricing, payment plan); only
/// the seller-only actions (submit for verification) are gated with `Can`, so
/// this same screen is reusable for a future buyer-facing detail route.
class ProjectDetailScreen extends GetView<ProjectDetailController> {
  const ProjectDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.state.value.valueOrNull?.title ?? Tr.projTitle.tr,
          ),
        ),
      ),
      body: Obx(
        () => AsyncView<RealEstateProject>(
          value: controller.state.value,
          onRetry: controller.reload,
          data: (p) => _body(context, p),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final p = controller.state.value.valueOrNull;
        if (p == null || !p.canSubmit) return const SizedBox.shrink();
        return Can(
          Perm.projectSubmit,
          child: SafeArea(
            minimum: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.submitError.value != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Text(
                      controller.submitError.value!,
                      style: TextStyle(color: context.colors.criticalInk),
                    ),
                  ),
                AppButton(
                  label: Tr.projSubmit.tr,
                  loading: controller.busy.value,
                  onPressed: () async {
                    final ok = await controller.submitForVerification();
                    if (ok) {
                      AppSnackbar.show(
                        Tr.projSubmitted.tr,
                        tone: FeedbackTone.success,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _body(BuildContext context, RealEstateProject p) {
    final c = context.colors;
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
            Icon(p.type.icon, color: c.inkMuted),
            SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(p.type.labelKey.tr, style: text.titleMedium)),
            AppStatusChip(p.status.labelKey.tr, tone: p.status.tone),
          ],
        ),
        if (p.description != null && p.description!.isNotEmpty) ...[
          SizedBox(height: AppSpacing.sm),
          Text(p.description!, style: text.bodyMedium),
        ],
        if (p.location != null) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel(Tr.projLocation.tr),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    p.location!.area,
                    if (p.location!.sector != null) p.location!.sector,
                    p.location!.district,
                    p.location!.division,
                  ].whereType<String>().join(', '),
                  style: text.bodyLarge,
                ),
                if (p.location!.landmarks.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    p.location!.landmarks.join(' · '),
                    style: text.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
        if (p.buildings.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel('${Tr.projBuildings.tr} · ${p.unitCount}'),
          for (final b in p.buildings) _BuildingBlock(project: p, building: b),
        ],
        if (p.amenities.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel(Tr.projAmenities.tr),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final a in p.amenities)
                Chip(
                  avatar: Icon(amenityIcon(a.icon), size: 16),
                  label: Text(a.name),
                ),
            ],
          ),
        ],
        if (p.pricing != null) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel(Tr.projPricing.tr),
          AppCard(
            child: Column(
              children: [
                _kv(context, Tr.projLandCost.tr, p.pricing!.landCost.toBdt()),
                _kv(
                  context,
                  Tr.projConstructionCost.tr,
                  p.pricing!.constructionCost.toBdt(),
                ),
                _kv(
                  context,
                  Tr.projConsultancyCost.tr,
                  p.pricing!.consultancyCost.toBdt(),
                ),
                _kv(
                  context,
                  Tr.projEstimatedTotal.tr,
                  p.pricing!.estimatedTotal.toBdt(),
                  emphasise: true,
                ),
              ],
            ),
          ),
        ],
        if (p.paymentPlans.isNotEmpty) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel(Tr.projPaymentPlan.tr),
          for (final plan in p.paymentPlans)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.name, style: text.titleSmall),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${plan.downPaymentPercent}% down · ${plan.installmentCount} installments',
                    style: text.bodySmall,
                  ),
                ],
              ),
            ),
        ],
        if (p.contactName != null || p.contactPhone != null) ...[
          SizedBox(height: AppSpacing.lg),
          AppSectionLabel(Tr.projContact.tr),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (p.contactName != null)
                  Text(p.contactName!, style: text.bodyLarge),
                if (p.contactPhone != null)
                  Text(p.contactPhone!, style: AppTypography.mono(c.inkMuted)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _kv(
    BuildContext context,
    String k,
    String v, {
    bool emphasise = false,
  }) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(k, style: text.bodyMedium)),
          Text(
            v,
            style: AppTypography.mono(
              emphasise ? c.brandInk : c.ink,
              weight: emphasise ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildingBlock extends StatelessWidget {
  const _BuildingBlock({required this.project, required this.building});

  final RealEstateProject project;
  final Building building;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${building.name} · ${building.floors} floor(s)',
            style: text.titleSmall,
          ),
          for (final u in building.units) ...[
            const Divider(height: 1),
            _UnitRow(project: project, unit: u),
          ],
        ],
      ),
    );
  }
}

class _UnitRow extends StatelessWidget {
  const _UnitRow({required this.project, required this.unit});

  final RealEstateProject project;
  final Unit unit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    final price = unit.prices.isEmpty ? null : unit.prices.first;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(unit.unitNumber, style: text.bodyLarge),
                    Text(
                      '${unit.sizeSqft.toInt()} sqft',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              if (price != null)
                Text(
                  price.amount.toBdt(decimals: false),
                  style: AppTypography.mono(c.ink),
                ),
              SizedBox(width: AppSpacing.sm),
              AppStatusChip(
                unit.status.labelKey.tr,
                tone: unit.status.tone,
                dot: false,
              ),
            ],
          ),
          if (unit.status == UnitStatus.available) ...[
            SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                Can(
                  Perm.siteVisitManage,
                  child: TextButton.icon(
                    onPressed: () => Get.toNamed<void>(
                      Routes.siteVisits,
                      arguments: (
                        projectId: project.id,
                        projectTitle: project.title,
                        unitId: unit.id,
                        unitName: unit.unitNumber,
                      ),
                    ),
                    icon: const Icon(Icons.event_outlined, size: 16),
                    label: Text(Tr.svSchedule.tr),
                  ),
                ),
                Can(
                  Perm.offerManage,
                  child: TextButton.icon(
                    onPressed: () => Get.toNamed<void>(
                      Routes.newOffer,
                      arguments: (
                        projectId: project.id,
                        projectTitle: project.title,
                        unitId: unit.id,
                        unitName: unit.unitNumber,
                      ),
                    ),
                    icon: const Icon(Icons.handshake_outlined, size: 16),
                    label: Text(Tr.offerMake.tr),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
