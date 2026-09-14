import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/traveller.dart';
import '../controllers/travellers_controller.dart';
import 'traveller_create_sheet.dart';

class TravellersScreen extends GetView<TravellersController> {
  const TravellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.travellersTitle.tr)),
      floatingActionButton: Can(
        Perm.travellerCreate,
        travelOnly: true,
        child: FloatingActionButton.extended(
          onPressed: () => showTravellerCreateSheet(controller),
          icon: const Icon(Icons.person_add_alt_1),
          label: Text(Tr.travNew.tr),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: AppSearchField(
              hint: Tr.travSearch.tr,
              onChanged: (v) => controller.query.value = v,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: Obx(
                () => AsyncView<List<Traveller>>(
                  value: controller.state.value,
                  onRetry: controller.load,
                  data: (_) {
                    final list = controller.visible;
                    if (list.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: AppSpacing.xxl),
                          const AppEmptyState(),
                        ],
                      );
                    }
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, i) => _TravellerRow(list[i]),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TravellerRow extends StatelessWidget {
  const _TravellerRow(this.traveller);

  final Traveller traveller;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return ListTile(
      leading: AppAvatar(name: traveller.name),
      title: Text(traveller.name),
      subtitle: Row(
        children: [
          if (traveller.passportNumber != null)
            Text(
              traveller.passportNumber!,
              style: AppTypography.mono(c.inkMuted, size: 12),
            ),
          if (traveller.passportExpired || traveller.passportExpiringSoon) ...[
            SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.warning_amber_rounded,
              size: 14,
              color: traveller.passportExpired ? c.criticalInk : c.signalInk,
            ),
          ],
        ],
      ),
      trailing: Text(
        '${traveller.tripCount} ${Tr.travTrips.tr}',
        style: text.bodySmall,
      ),
      onTap: () =>
          Get.toNamed<void>(Routes.travellerDetail, arguments: traveller),
    );
  }
}
