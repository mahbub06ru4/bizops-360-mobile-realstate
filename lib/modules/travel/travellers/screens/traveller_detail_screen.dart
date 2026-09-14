import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/traveller.dart';
import '../controllers/traveller_detail_controller.dart';

class TravellerDetailScreen extends GetView<TravellerDetailController> {
  const TravellerDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.traveller.value.valueOrNull?.name ?? ''),
        ),
      ),
      body: Obx(
        () => AsyncView<Traveller>(
          value: controller.traveller.value,
          data: (t) => _body(context, t),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, Traveller t) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final df = DateFormat.yMMMd();

    ChipTone? passportTone;
    String? passportWarning;
    if (t.passportExpired) {
      passportTone = ChipTone.critical;
      passportWarning = Tr.travPassportExpired.tr;
    } else if (t.passportExpiringSoon) {
      passportTone = ChipTone.signal;
      passportWarning = Tr.travPassportSoon.tr;
    }

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
            AppAvatar(name: t.name, size: 52),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name, style: text.headlineSmall),
                  Text(
                    '${t.nationality}'
                    '${t.phone == null ? '' : ' · ${t.phone}'}',
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.lg),
        AppSectionLabel(Tr.travPassport.tr),
        SizedBox(height: AppSpacing.xs),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kv(
                context,
                Tr.travPassportNo.tr,
                t.passportNumber ?? '—',
                mono: true,
              ),
              _kv(
                context,
                Tr.travExpiry.tr,
                t.passportExpiry == null ? '—' : df.format(t.passportExpiry!),
              ),
              _kv(
                context,
                Tr.travDob.tr,
                t.dateOfBirth == null ? '—' : df.format(t.dateOfBirth!),
              ),
              if (passportWarning != null) ...[
                SizedBox(height: AppSpacing.xs),
                AppStatusChip(passportWarning, tone: passportTone!, dot: false),
              ],
            ],
          ),
        ),
        SizedBox(height: AppSpacing.xl),
        AppSectionLabel(Tr.travHistory.tr),
        SizedBox(height: AppSpacing.xs),
        Obx(
          () => AsyncView<List<TravelHistoryEntry>>(
            value: controller.history.value,
            isEmpty: (l) => l.isEmpty,
            data: (items) => Column(
              children: [
                for (final e in items)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.flight_takeoff, color: c.inkMuted),
                    title: Text(e.destination),
                    subtitle: Text(e.purpose),
                    trailing: Text(
                      DateFormat.yMMM().format(e.date),
                      style: text.bodySmall,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v, {bool mono = false}) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(k, style: text.bodyMedium)),
          Text(
            v,
            style: mono
                ? AppTypography.mono(context.colors.ink)
                : text.titleMedium,
          ),
        ],
      ),
    );
  }
}
