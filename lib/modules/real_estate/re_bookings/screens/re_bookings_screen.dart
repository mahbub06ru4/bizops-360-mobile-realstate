import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/extensions/money_format.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/real_estate_booking.dart';
import '../../pipeline_display.dart';
import '../controllers/re_bookings_controller.dart';

class ReBookingsScreen extends GetView<ReBookingsController> {
  const ReBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.bookTitle.tr)),
      body: RefreshIndicator(
        onRefresh: controller.load,
        child: Obx(
          () => AsyncView<List<RealEstateBooking>>(
            value: controller.state.value,
            onRetry: controller.load,
            isEmpty: (l) => l.isEmpty,
            empty: ListView(
              children: [
                SizedBox(height: AppSpacing.xxl),
                AppEmptyState(message: Tr.bookEmpty.tr),
              ],
            ),
            data: (bookings) => ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: bookings.length,
              itemBuilder: (context, i) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: _BookingCard(booking: bookings[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final RealEstateBooking booking;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () =>
          Get.toNamed<void>(Routes.reBookingDetail, arguments: booking),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(booking.leadName, style: text.titleMedium)),
              AppStatusChip(
                booking.status.labelKey.tr,
                tone: booking.status.tone,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            '${booking.projectTitle} · ${booking.unitName}',
            style: text.bodyMedium,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            booking.agreedPrice.toBdt(decimals: false),
            style: text.bodyLarge,
          ),
        ],
      ),
    );
  }
}
