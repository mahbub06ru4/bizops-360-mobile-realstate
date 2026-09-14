import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/money_format.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/permissions/can.dart';
import '../../../../core/permissions/permissions.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/offer.dart';
import '../../pipeline_display.dart';
import '../controllers/offer_thread_controller.dart';

/// A negotiation thread rendered as a vertical timeline of offer/counter
/// cards, oldest first — "structured Offer, not chat" (roadmap §7).
class OfferThreadScreen extends GetView<OfferThreadController> {
  const OfferThreadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.offerTitle.tr)),
      body: Obx(
        () => AsyncView<List<Offer>>(
          value: controller.state.value,
          onRetry: controller.load,
          data: (chain) => ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              for (var i = 0; i < chain.length; i++)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _OfferNode(
                    offer: chain[i],
                    isLatest: i == chain.length - 1,
                  ),
                ),
              if (controller.error.value != null) ...[
                SizedBox(height: AppSpacing.sm),
                Text(
                  controller.error.value!,
                  style: TextStyle(color: context.colors.criticalInk),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final head = controller.latest;
        if (head == null) return const SizedBox.shrink();
        return SafeArea(
          minimum: EdgeInsets.all(AppSpacing.lg),
          child: _Actions(head: head),
        );
      }),
    );
  }
}

class _OfferNode extends StatelessWidget {
  const _OfferNode({required this.offer, required this.isLatest});

  final Offer offer;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(offer.offeredBy.icon, size: 20, color: c.inkMuted),
            if (!isLatest) Container(width: 2, height: 40, color: c.line),
          ],
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(offer.offeredBy.labelKey.tr, style: text.labelSmall),
                    const Spacer(),
                    AppStatusChip(
                      offer.status.labelKey.tr,
                      tone: offer.status.tone,
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  offer.offeredPrice.toBdt(decimals: false),
                  style: text.titleLarge,
                ),
                if (offer.notes != null && offer.notes!.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Text(offer.notes!, style: text.bodySmall),
                ],
                if (offer.createdAt != null) ...[
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    DateFormat.yMMMEd().add_jm().format(offer.createdAt!),
                    style: text.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.head});

  final Offer head;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OfferThreadController>();

    if (head.status == OfferStatus.accepted) {
      return Can(
        Perm.bookingManage,
        child: AppButton(
          label: Tr.offerReserveBooking.tr,
          loading: controller.busy.value,
          onPressed: () async {
            final bookingId = await controller.reserveBooking();
            if (bookingId != null) {
              AppSnackbar.show(
                Tr.offerBookingReserved.tr,
                tone: FeedbackTone.success,
              );
              unawaited(
                Get.toNamed<void>(Routes.reBookingDetail, arguments: bookingId),
              );
            }
          },
        ),
      );
    }

    if (head.status != OfferStatus.pending &&
        head.status != OfferStatus.countered) {
      return const SizedBox.shrink();
    }

    return Can(
      Perm.offerManage,
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: Tr.offerReject.tr,
              variant: AppButtonVariant.secondary,
              onPressed: () => controller.reject().then((ok) {
                if (ok) {
                  AppSnackbar.show(
                    Tr.offerRejected.tr,
                    tone: FeedbackTone.warning,
                  );
                }
              }),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              label: Tr.offerAccept.tr,
              onPressed: () => controller.accept().then((ok) {
                if (ok) {
                  AppSnackbar.show(
                    Tr.offerAccepted.tr,
                    tone: FeedbackTone.success,
                  );
                }
              }),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              label: Tr.offerCounter.tr,
              variant: AppButtonVariant.text,
              onPressed: () => _showCounterSheet(context, controller, head),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCounterSheet(
    BuildContext context,
    OfferThreadController controller,
    Offer head,
  ) {
    final amountController = TextEditingController(
      text: head.offeredPrice.toString(),
    );
    final noteController = TextEditingController();
    final counterBy = head.offeredBy == OfferParty.seller
        ? OfferParty.buyer
        : OfferParty.seller;

    return AppBottomSheet.show<void>(
      Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Tr.offerCounter.tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.offerAmount.tr,
              controller: amountController,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              label: Tr.offerNote.tr,
              controller: noteController,
              maxLines: 2,
            ),
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: Tr.offerCounter.tr,
              onPressed: () async {
                final amount = num.tryParse(amountController.text.trim());
                if (amount == null) return;
                final ok = await controller.counter(
                  offeredPrice: amount,
                  by: counterBy,
                  notes: noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim(),
                );
                if (ok) {
                  Get.back<void>();
                  AppSnackbar.show(
                    Tr.offerCountered.tr,
                    tone: FeedbackTone.success,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
