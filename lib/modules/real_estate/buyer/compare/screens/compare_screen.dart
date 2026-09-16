import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/extensions/money_format.dart';
import '../../../../../core/localization/translation_keys.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../domain/entities/real_estate_project.dart';
import '../../../projects/project_display.dart';
import '../controllers/compare_controller.dart';

/// Side-by-side comparison of the projects the buyer picked on the Saved tab
/// (roadmap §7 Phase 2 DoD: "compare 3 projects"). Laid out as one horizontal
/// column per project inside a horizontally scrolling row, each row a fact
/// (price, location, unit types, amenities, verification).
class CompareScreen extends GetView<CompareController> {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.buyerCompareTitle.tr)),
      body: Obx(
        () => AsyncView<List<RealEstateProject>>(
          value: controller.state.value,
          onRetry: controller.load,
          data: (projects) => SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FactColumn(
                    label: '',
                    rows: const [
                      '',
                      Tr.buyerCompareDeveloper,
                      Tr.buyerComparePrice,
                      Tr.buyerCompareLocation,
                      Tr.buyerCompareUnitTypes,
                      Tr.buyerCompareAmenities,
                      Tr.buyerCompareVerification,
                    ].map((k) => k.isEmpty ? '' : k.tr).toList(),
                    isHeader: true,
                  ),
                  for (final p in projects) _ProjectColumn(project: p),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FactColumn extends StatelessWidget {
  const _FactColumn({
    required this.label,
    required this.rows,
    this.isHeader = false,
  });

  final String label;
  final List<String> rows;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    return SizedBox(
      width: isHeader ? 120 : 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final r in rows)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                r,
                style: isHeader
                    ? text.labelMedium?.copyWith(color: c.inkMuted)
                    : text.bodyMedium,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProjectColumn extends StatelessWidget {
  const _ProjectColumn({required this.project});

  final RealEstateProject project;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final unitTypes = project.buildings
        .expand((b) => b.units)
        .map((u) => '${u.unitNumber} (${u.sizeSqft.toInt()} sqft)')
        .toList();

    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.md),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                project.title,
                style: text.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _row(context, project.developerName ?? '—'),
            _row(
              context,
              project.pricing?.estimatedTotal.toBdt(decimals: false) ?? '—',
            ),
            _row(context, project.location?.shortLabel ?? '—'),
            _row(context, unitTypes.isEmpty ? '—' : unitTypes.join(', ')),
            _row(
              context,
              project.amenities.isEmpty
                  ? '—'
                  : project.amenities.map((a) => a.name).join(', '),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: AppStatusChip(
                project.status.labelKey.tr,
                tone: project.status.tone,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
