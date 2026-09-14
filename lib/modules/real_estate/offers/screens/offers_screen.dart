import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/money_format.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/offer.dart';
import '../../pipeline_display.dart';
import '../controllers/offers_controller.dart';

class OffersScreen extends GetView<OffersController> {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.offerTitle.tr)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<Offer>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (l) => l.isEmpty,
            empty: ListView(
              children: [
                SizedBox(height: AppSpacing.xxl),
                AppEmptyState(message: Tr.offerEmpty.tr),
              ],
            ),
            data: (offers) => ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: offers.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _ThreadCard(offer: offers[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.offer});

  final Offer offer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => Get.toNamed<void>(Routes.offerThread, arguments: offer.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(offer.leadName, style: text.titleMedium)),
              AppStatusChip(offer.status.labelKey.tr, tone: offer.status.tone),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            '${offer.projectTitle} · ${offer.unitName}',
            style: text.bodyMedium,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            offer.offeredPrice.toBdt(decimals: false),
            style: text.bodyLarge,
          ),
        ],
      ),
    );
  }
}
