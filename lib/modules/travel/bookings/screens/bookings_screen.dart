import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/extensions/money_format.dart';
import '../../../../core/localization/translation_keys.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/entities/booking.dart';
import '../booking_display.dart';
import '../controllers/bookings_controller.dart';
import 'booking_create_sheet.dart';

class BookingsScreen extends GetView<BookingsController> {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tr.bookingsTitle.tr)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final created = await showBookingCreateSheet(controller);
          if (created) {
            AppSnackbar.show(Tr.bkCreated.tr, tone: FeedbackTone.success);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(Tr.bkNew.tr),
      ),
      body: Column(
        children: [
          Obx(
            () => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                children: [
                  for (final s in BookingStatus.values)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: FilterChip(
                        label: Text(s.labelKey.tr),
                        selected: controller.statusFilter.value == s,
                        onSelected: (_) => controller.toggleStatus(s),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: Obx(
                () => AsyncView<List<Booking>>(
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
                    return ListView.builder(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      itemCount: list.length,
                      itemBuilder: (context, i) => Padding(
                        padding: EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _BookingCard(booking: list[i]),
                      ),
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

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: () => Get.toNamed<void>(Routes.bookingDetail, arguments: booking),
      child: Row(
        children: [
          Icon(booking.kind.icon, color: c.inkMuted),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(booking.reference, style: AppTypography.mono(c.ink)),
                    SizedBox(width: AppSpacing.sm),
                    Text(booking.travellerName, style: text.bodySmall),
                  ],
                ),
                Text(
                  '${DateFormat.MMMd().format(booking.travelDate)} · ${booking.amount.toBdt(decimals: false)}',
                  style: text.bodySmall,
                ),
              ],
            ),
          ),
          AppStatusChip(booking.status.labelKey.tr, tone: booking.status.tone),
        ],
      ),
    );
  }
}
